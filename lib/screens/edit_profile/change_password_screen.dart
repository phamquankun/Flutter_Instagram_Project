import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/widgets/centered_text.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cool_alert/cool_alert.dart';

TextEditingController editController = TextEditingController();
TextEditingController editController1 = TextEditingController();

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Changed Password'),
        ),
        body: Center(
            // margin: EdgeInsets.all(16),
            child: Padding(
          padding: const EdgeInsets.only(right: 24, left: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xff7c94b6),
                  image: const DecorationImage(
                    image: AssetImage('assets/lock.gif'),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: Colors.black,
                    width: 8,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              TextField(
                controller: editController1,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Current password",
                    hintText: "Enter current password",
                    border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: editController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "New password",
                    hintText: "Enter new password",
                    border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  color: Colors.blue,
                  onPressed: () {
                    resetPassword(context);
                  },
                  child: Text(
                    "Reset password",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        )));
  }

  void resetPassword(BuildContext context) async {
    if (editController.text.length < 6 || editController1.text.length < 6) {
      Fluttertoast.showToast(msg: "Must be at least 6 characters.");
      return;
    } else {
      User user = FirebaseAuth.instance.currentUser;
      try {
        AuthCredential credential = EmailAuthProvider.credential(
            email: user.email, password: editController1.text);

        FirebaseAuth.instance.currentUser
            .reauthenticateWithCredential(credential);
      } catch (e) {
        CoolAlert.show(
          context: context,
          type: CoolAlertType.warning,
          text: 'Current password was incorrect',
        );
        return;
      }

      try {
        user.updatePassword(editController.text);
      } catch (e) {
        print("Exception raise !! $e");
      }
      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: 'Change password successful',
      );
      // Fluttertoast.showToast(msg: "Update password sucessfully");
      // Navigator.pop(context);
    }
  }
}
