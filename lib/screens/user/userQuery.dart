import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserQuery extends StatefulWidget {
  final String userId;

  UserQuery({required this.userId});

  @override
  _UserQueryState createState() => _UserQueryState();
}

class _UserQueryState extends State<UserQuery> {
  final TextEditingController _questionController = TextEditingController();

  Future<void> _postQuestion() async {
    if (_questionController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('queries').add({
      'userId': widget.userId,
      'question': _questionController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _questionController.clear();
  }

  Future<String> getDentistName(String dentistId) async {
    var doc = await FirebaseFirestore.instance.collection('users').doc(dentistId).get();
    return doc.exists ? doc['userName'] : "Dentist";
  }

  Future<void> _editQuestion(String queryId, String currentText) async {
    _questionController.text = currentText;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Question"),
          content: TextField(
            controller: _questionController,
            decoration: InputDecoration(border: OutlineInputBorder()),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _questionController.clear();
                Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(fontFamily: 'GoogleSans'),),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_questionController.text.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('queries')
                      .doc(queryId)
                      .update({'question': _questionController.text});
                  _questionController.clear();
                }
                Navigator.pop(context);
              },
              child: Text("Update", style: TextStyle(fontFamily: 'GoogleSans'),),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteQuestion(String queryId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Delete", style: TextStyle(fontFamily: 'GoogleSans'),),
          content: Text("Are you sure you want to delete this question?", style: TextStyle(fontFamily: 'GoogleSans'),),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(fontFamily: 'GoogleSans'),),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('queries').doc(queryId).delete();
                Navigator.pop(context);
              },
              child: Text("Delete", style: TextStyle(fontFamily: 'GoogleSans', color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            "User Queries",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'GoogleSans',
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.0),
            child: Container(
              color: Colors.white,
              child: TabBar(
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: [
                  Tab(text: "Ask Question"),
                  Tab(text: "Your Questions"),
                ],
              ),
            ),
          ),
        ),

        body: TabBarView(
          children: [
            /// Tab 1: Ask a Question
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      labelText: "Enter your question",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _postQuestion,
                    child: Text("Post Question", style: TextStyle(fontFamily: 'GoogleSans', color: Colors.blue),),
                  ),
                ],
              ),
            ),

            /// Tab 2: View Previously Asked Questions + Replies
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('queries')
                  .where('userId', isEqualTo: widget.userId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(fontFamily: 'GoogleSans'),));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No questions found.", style: TextStyle(fontFamily: 'GoogleSans'),));
                }

                var queries = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: queries.length,
                  itemBuilder: (context, index) {
                    var queryData = queries[index];
                    String queryId = queryData.id;
                    String question = queryData['question'];
                    Timestamp? timestamp = queryData['timestamp'];

                    return Card(
                      margin: EdgeInsets.all(8),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Display User's Question
                            Text(question, style: TextStyle(fontFamily: 'GoogleSans',fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                              timestamp != null
                                  ? timeago.format(timestamp.toDate())
                                  : "Just now",
                              style: TextStyle(fontFamily: 'GoogleSans',color: Colors.grey),
                            ),

                            /// Fetch & Display Replies
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('queries')
                                  .doc(queryId)
                                  .collection('replies')
                                  .orderBy('timestamp', descending: true)
                                  .snapshots(),
                              builder: (context, replySnapshot) {
                                if (replySnapshot.hasError) {
                                  return Text("Error loading replies: ${replySnapshot.error}", style: TextStyle(fontFamily: 'GoogleSans'),);
                                }

                                if (!replySnapshot.hasData || replySnapshot.data!.docs.isEmpty) {
                                  return Text("No replies yet", style: TextStyle(fontFamily: 'GoogleSans', color: Colors.grey));
                                }

                                var replies = replySnapshot.data!.docs;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                padding: EdgeInsets.only(top:20),
                                    child: Text("Replies:", style: TextStyle(fontFamily: 'GoogleSans', fontSize: 16)),
                                    ),
                                    ...replies.map((reply) {
                                      String replyText = reply['reply'];
                                      String dentistId = reply['dentistId'];


                                      return FutureBuilder<String>(
                                        future: getDentistName(dentistId),
                                        builder: (context, nameSnapshot) {
                                          if (nameSnapshot.connectionState == ConnectionState.waiting) {
                                            return Text("Loading...");
                                          }
                                          String dentistName = nameSnapshot.data ?? "Dentist";

                                          return Padding(
                                            padding: EdgeInsets.only(top: 6),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                          children:[
                                            Text("Dr. $dentistName",
                                                style: TextStyle(fontFamily: 'GoogleSans', color: Colors.blue)),
                                          Text("$replyText",
                                          style: TextStyle(fontFamily: 'GoogleSans', color: Color(0xFF6B6969))),
                                          ],
                                          ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ],
                                );
                              },
                            ),

                            /// Edit & Delete Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editQuestion(queryId, question),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteQuestion(queryId),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
