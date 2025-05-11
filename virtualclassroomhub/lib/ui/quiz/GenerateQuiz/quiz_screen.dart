import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtualclassroomhub/ui/TeacherScreens/teacher_dashboard.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> quiz = [];
  bool isLoading = false;
  String error = '';
  String extractedText = '';
  int numberOfQuestions = 5;
  String selectedDifficulty = 'medium';
  String selectedQuizType = 'mcq';
  String quizCode = '';

  Future<void> pickPdfAndExtractText() async {
    setState(() {
      isLoading = true;
      quiz.clear();
      error = '';
      extractedText = '';
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileBytes = File(filePath).readAsBytesSync();

        final PdfDocument document = PdfDocument(inputBytes: fileBytes);
        final PdfTextExtractor textExtractor = PdfTextExtractor(document);
        extractedText = textExtractor.extractText();
        document.dispose();

        if (extractedText.isNotEmpty) {
          await fetchQuizInChunks(extractedText);
        } else {
          setState(() {
            error = 'No text could be extracted from the PDF.';
          });
        }
      } else {
        setState(() {
          error = 'No file selected.';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error reading PDF: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchQuizInChunks(String text) async {
    const int chunkSize = 3000;
    final chunks = <String>[];

    for (int i = 0; i < text.length; i += chunkSize) {
      chunks.add(text.substring(i, i + chunkSize > text.length ? text.length : i + chunkSize));
    }

    List<dynamic> allQuestions = [];
    setState(() {
      isLoading = true;
      error = '';
    });

    for (int i = 0; i < chunks.length; i++) {
      final chunk = chunks[i];
      final url = Uri.parse("https://junaidkhattak252-quizzz-app.hf.space/generatee-quiz");
      int questionsPerChunk = numberOfQuestions;

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "pdf_text": chunk,
            "difficulty": selectedDifficulty,
            "quiz_type": selectedQuizType,
            "number_of_questions": questionsPerChunk,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is List) {
            for (var q in data) {
              if (selectedQuizType == 'mcq') {
                if (!allQuestions.any((existing) => existing['mcq'] == q['mcq'])) {
                  allQuestions.add(q);
                }
              } else if (selectedQuizType == 'comprehensive') {
                if (!allQuestions.any((existing) => existing['question'] == q['question'])) {
                  allQuestions.add(q);
                }
              }
            }
          } else {
            setState(() {
              error = 'Unexpected response format in chunk ${i + 1}';
            });
          }
        } else {
          setState(() {
            error = 'Chunk ${i + 1} failed with status: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          error = 'API error in chunk ${i + 1}: ${e.toString()}';
        });
      }
    }

    allQuestions.shuffle(Random());
    quiz = allQuestions.take(numberOfQuestions).toList();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveQuizToFirestore() async {
    if (quizCode.isEmpty) {
      setState(() {
        error = "Please enter a quiz code.";
      });
      return;
    }

    try {
      final quizCollection = FirebaseFirestore.instance.collection('quizzes');
      final quizDocRef = quizCollection.doc(quizCode);

      await quizDocRef.set({
        'quizData': quiz,
        'quizType': selectedQuizType,
      });

      // After successfully saving, show a beautiful dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success!'),
          content: const Text('Quiz uploaded successfully.'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to dashboard
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        error = "Error saving quiz: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teacher Quiz Generator")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : quiz.isEmpty
          ? SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Quiz Code",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => quizCode = value.trim(),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedDifficulty,
              decoration: const InputDecoration(
                labelText: "Difficulty",
                border: OutlineInputBorder(),
              ),
              items: ['easy', 'medium', 'hard']
                  .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => selectedDifficulty = value);
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedQuizType,
              decoration: const InputDecoration(
                labelText: "Quiz Type",
                border: OutlineInputBorder(),
              ),
              items: ['mcq', 'comprehensive']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => selectedQuizType = value);
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: numberOfQuestions.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Number of Questions",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  numberOfQuestions = int.tryParse(value) ?? 5;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: quizCode.isNotEmpty ? pickPdfAndExtractText : null,
              child: const Text("Pick PDF & Generate Quiz"),
            ),
            if (error.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(error, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: quiz.length,
                itemBuilder: (context, index) {
                  final question = quiz[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (selectedQuizType == 'mcq') ...[
                            Text(
                              "Q${index + 1}: ${question['mcq']}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...question['options'].entries.map(
                                  (entry) => ListTile(
                                title: Text("${entry.key.toUpperCase()}. ${entry.value}"),
                              ),
                            ),
                            Text(
                              "Correct Answer: ${question['correct'].toUpperCase()}",
                              style: const TextStyle(color: Colors.green),
                            ),
                          ] else if (selectedQuizType == 'comprehensive') ...[
                            Text(
                              "Q${index + 1}: ${question['question']}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 5),
                            Text(
                              "Answer: ${question['expected_answer']}",
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              ElevatedButton(
                onPressed: saveQuizToFirestore,
                child: const Text("Upload"),
              ),
              if (error.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(error, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
