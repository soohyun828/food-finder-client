import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'signupSuccess.dart';
import 'login.dart';


// String serverURL = "http://127.0.0.1:5000"; // 그냥 컴에서 돌릴때
// String serverURL = "http://10.0.2.2:5000"; // 가상 에뮬레이터
String serverURL = "http://192.168.35.96:5000"; // 실제 기기



class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('회원 가입'),
      ),
      body: const SignupForm(),
    );
  }
}


class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  SignupFormState createState() => SignupFormState();
}

class PersonData {
  String? username = '';
  String? phoneNumber = '';
  String? password = '';
}


class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    this.restorationId,
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.focusNode,
    this.textInputAction,
  });

  final String? restorationId;
  final Key? fieldKey;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}


class _PasswordFieldState extends State<PasswordField>
    with RestorationMixin {
  final RestorableBool _obscureText = RestorableBool(true);

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_obscureText, 'obscure_text');
  }

  @override
  Widget build(BuildContext context) {
    
    return TextFormField(
      key: widget.fieldKey,
      restorationId: 'password_text_field',
      obscureText: _obscureText.value,
      maxLength: 8,
      onSaved: widget.onSaved,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        filled: true,
        hintText: widget.hintText,
        labelText: widget.labelText,
        helperText: widget.helperText,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureText.value = !_obscureText.value;
            });
          },
          hoverColor: Colors.transparent,
          icon: Icon(
            _obscureText.value ? Icons.visibility : Icons.visibility_off,
          ),
        ),
      ),
    );
  }
}



class SignupFormState extends State<SignupForm>
    with RestorationMixin {
  PersonData person = PersonData();

  bool isUsernameAvailable = true;

  TextEditingController controller = TextEditingController();

  late FocusNode _phoneNumber, _password, _retypePassword;

  @override
  void initState() {
    super.initState();
    _phoneNumber = FocusNode();
    _password = FocusNode();
    _retypePassword = FocusNode();
  }

  @override
  void dispose() {
    _phoneNumber.dispose();
    _password.dispose();
    _retypePassword.dispose();
    super.dispose();
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
    ));
  }  

    
  @override
  String get restorationId => 'signup';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_autoValidateModeIndex, 'autovalidate_mode');
  }

  final RestorableInt _autoValidateModeIndex =
      RestorableInt(AutovalidateMode.disabled.index);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
      GlobalKey<FormFieldState<String>>();
  final _KrNumberTextInputFormatter _phoneNumberFormatter =
      _KrNumberTextInputFormatter();


  void Function()? _checkUsernameAvailability(String id) {
    // final form = _formKey.currentState!;
    // if (!form.validate()) {
    //   _autoValidateModeIndex.value = AutovalidateMode.always.index;
    //   return null;
    // }

    // form.save();

    try {
      http.get(
        Uri.parse('$serverURL/home/check_username/$id'),
      ).then((response) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data.containsKey('success') && data.containsKey('message')) {
            showInSnackBar(data['message']);
            setState(() {
              isUsernameAvailable = data['success'];
            });
          } else {
            showInSnackBar('서버 응답 형식이 올바르지 않습니다.');
          }
        } else {
          showInSnackBar('서버 오류: ${response.statusCode}');
        }
      }).catchError((e) {
        showInSnackBar('오류가 발생했습니다. $e');
      });

      return null;
    } catch (e) {
      showInSnackBar('오류가 발생했습니다. $e');
      return null;
    }
  }




  Future<void> _handleSubmitted() async {
    final form = _formKey.currentState!;
    
    if (!form.validate()) {
      _autoValidateModeIndex.value = 
          AutovalidateMode.always.index; 
      showInSnackBar(
        "Form errors",
      );
    } else {
      // 회원가입 성공 시
      form.save();
      final response = await http.post(
        Uri.parse('$serverURL/home/signup'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": person.username,
          "phoneNumber": person.phoneNumber,
          "password": person.password,
        }),
      );


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          // 회원가입 성공 시 signupSuccess 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignupSuccess(username: person.username!),
            ),
          );
        } else {
          showInSnackBar('회원가입에 실패했습니다. 다시 시도해주세요.');
        }
      } else {
        showInSnackBar('서버 오류: ${response.statusCode}');
      }
    }
  }
  

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "ID를 입력하세요.";
    }
    final usernameExp = RegExp(r'^[a-zA-Z0-9]*$');
    if (!usernameExp.hasMatch(value)) {
      return "알파벳과 숫자만 허용됩니다.";
    }
    return null;
  }


  String? _validatePhoneNumber(String? value) {
    final phoneExp = RegExp(r'^\d\d\d\-\d\d\d\d-\d\d\d\d$');
    if (!phoneExp.hasMatch(value!)) {
      return "Enter a valid phone number";
    }
    return null;
  }


  String? _validatePassword(String? value) {
    final passwordField = _passwordFieldKey.currentState!;
    if (passwordField.value == null || passwordField.value!.isEmpty) {
      return "Enter a password";
    }
    if (passwordField.value != value) {
      return "Passwords do not match";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 24);

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.values[_autoValidateModeIndex.value],
      child: Scrollbar(
        child: SingleChildScrollView(
          restorationId: 'signup_scroll_view',
          padding: const EdgeInsets.symmetric(horizontal: 16),
          
          child: Column(

            children: [
              sizedBoxSpace,
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      restorationId: 'id_field',
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        filled: true,
                        icon: Icon(Icons.person),
                        labelText: "ID",
                      ),
                      onSaved: (value) {
                        person.username = value;
                        // _phoneNumber.requestFocus();
                      },
                      validator: _validateName,
                    ),
                  ),

                  sizedBoxSpace,
                  ElevatedButton(
                    onPressed: () {
                      _checkUsernameAvailability(controller.text);
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 255, 174, 0).withOpacity(0.5),
                        ),
                      ),
                    child: const Text(
                      '중복확인',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              sizedBoxSpace,
              TextFormField(
                restorationId: 'phone_number_field',
                textInputAction: TextInputAction.next,
                focusNode: _phoneNumber,
                decoration: const InputDecoration(
                  filled: true,
                  icon: Icon(Icons.phone),
                  labelText: "Phone Number",
                  prefixText: '+82 ',
                ),
                keyboardType: TextInputType.phone,
                onSaved: (value) {
                  person.phoneNumber = value;
                  _phoneNumber.requestFocus();
                },
                maxLength: 13,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                validator: _validatePhoneNumber,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  _phoneNumberFormatter,
                ],
              ),
              sizedBoxSpace,
              PasswordField(
                restorationId: 'password_field',
                textInputAction: TextInputAction.next,
                focusNode: _password,
                fieldKey: _passwordFieldKey,
                helperText: "No more than 8 characters",
                labelText: "Password",
                
                onFieldSubmitted: (value) {
                  setState(() {
                    person.password = value;
                    _retypePassword.requestFocus();
                  });
                },
                onSaved: (value) {
                  person.password = value;
                  _phoneNumber.requestFocus();
                },
              ),
              sizedBoxSpace,
              TextFormField(
                restorationId: 'retype_password_field',
                focusNode: _retypePassword,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: "Retype Password",
                ),
                maxLength: 8,
                obscureText: true,
                validator: _validatePassword,
                onFieldSubmitted: (value) {
                  _handleSubmitted();
                },
              ),

              sizedBoxSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 255, 174, 0).withOpacity(0.6))),
                        onPressed: () async{
                          _handleSubmitted();
 
                          FocusScope.of(context).unfocus();
 
                        },
                        child: const Text(
                          '회원가입',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ),
                  ],
                ),
                sizedBoxSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("이미 계정이 있으신가요?"),
                    // Text(" Login", style: TextStyle(
                    //   fontWeight: FontWeight.w600, fontSize: 18
                    // ),),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Login(),  // login.dart 페이지로 이동
                          ),
                        );
                      },
                      child: const Text(
                        " Login",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color.fromARGB(255, 132, 29, 201),
                        ),
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}

class _KrNumberTextInputFormatter extends TextInputFormatter {
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {

    final newTextLength = newValue.text.length;
    final newText = StringBuffer();
    var selectionIndex = newValue.selection.end;
    var usedSubstringIndex = 0;

    if (newTextLength >= 3) {
      newText.write('${newValue.text.substring(0, usedSubstringIndex = 3)}-');
      if (newValue.selection.end >= 3) selectionIndex++;
    }

    if (newTextLength >= 8) {
      newText.write('${newValue.text.substring(3, usedSubstringIndex = 7)}-');
      if (newValue.selection.end >= 7) selectionIndex++;
    }

    if (newTextLength >= 12) {
      newText.write(newValue.text.substring(7, usedSubstringIndex = 11));
    }

    if (newTextLength >= usedSubstringIndex) {
      newText.write(newValue.text.substring(usedSubstringIndex));
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}