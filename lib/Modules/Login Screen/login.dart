import 'package:digilib/Services/login_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  late String _captchaUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCaptcha();
  }

  void _loadCaptcha() async {
    setState(() {
      _captchaUrl = 'https://api-digilib.000webhostapp.com/captcha.php';
    });
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final loginService = LoginService();
      final response = await loginService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (response.containsKey('error')) {
        _showError(response['error']);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userID', response['id_user']);
        prefs.setString('userName', response['nama_user']);
        prefs.setString('userEmail', response['email']);
        prefs.setString('userGroupID', response['id_group_user']);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/book_logo.png',
                      width: 60,
                      height: 60,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Digilib',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Aswa Media',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 10),
                    _captchaUrl != null
                        ? Image.network(
                            _captchaUrl,
                            height: 90,
                            width: double.infinity,
                            fit: BoxFit.fill,
                          )
                        : CircularProgressIndicator(),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: _captchaController,
                        decoration: InputDecoration(
                          labelText: 'Captcha',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 10),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            child: Text('Login'),
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 10),
                            ),
                          ),
                    TextButton(
                      child: Text('Lupa password?'),
                      onPressed: () {
                        // Handle forgot password
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
