import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:quick_feedback/quick_feedback.dart';
import 'package:waterapp/gloabal_variables.dart';

class RateReview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return QuickFeedback(
      title: 'Leave a feedback', // Title of dialog
      showTextBox: true, // default false
      textBoxHint:
          'Share your feedback', // Feedback text field hint text default: Tell us more
      submitText: 'SUBMIT', // submit button text default: SUBMIT
      onSubmitCallback: (feedback) {
        //print('$feedback'); // map { rating: 2, feedback: 'some feedback' }
        Navigator.pop(context, '$feedback');
        ratingsList = feedback.values.toList();
        //print('$feedback');
        //var x = feedback["rating"];
        //print('$x');
      },
      askLaterText: 'ASK LATER',
      onAskLaterCallback: () {
        //Navigator.pop(context, 'no');
        Navigator.pop(context);
      },
    );
  }
}
