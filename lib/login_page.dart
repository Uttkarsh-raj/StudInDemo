import 'package:flutter/material.dart';
import 'package:linkedin_login/linkedin_login.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart' as Constant;

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  UserObject? user;
  bool logoutUser = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: LinkedInButtonStandardWidget(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => LinkedInUserWidget(
                        appBar: AppBar(
                          title: const Text('OAuth User'),
                        ),
                        destroySession: logoutUser,
                        redirectUrl: 'https://www.linkedin.com/signin-linkedin',
                        clientId: '86y2ltfjodl3bg',
                        clientSecret: 'JwTzXLSkXdhdGRca',
                        projection: const [
                          ProjectionParameters.id,
                          ProjectionParameters.localizedFirstName,
                          ProjectionParameters.localizedLastName,
                          ProjectionParameters.firstName,
                          ProjectionParameters.lastName,
                          ProjectionParameters.profilePicture,
                        ],
                        onGetUserProfile:
                            (final UserSucceededAction linkedInUser) {
                          print(
                            'Access token ${linkedInUser.user.token.accessToken}',
                          );

                          print('User id: ${linkedInUser.user.userId}');

                          user = UserObject(
                            firstName:
                                linkedInUser.user.firstName?.localized?.label,
                            lastName:
                                linkedInUser.user.lastName?.localized?.label,
                            email: linkedInUser.user.email?.elements![0]
                                .handleDeep?.emailAddress,
                            profileImageUrl: linkedInUser
                                .user
                                .profilePicture
                                ?.displayImageContent
                                ?.elements![0]
                                .identifiers![0]
                                .identifier,
                          );

                          setState(() {
                            logoutUser = false;
                          });

                          Navigator.pop(context);
                        },
                      ),
                      fullscreenDialog: true,
                    ),
                  );
                },
                buttonText: "Login using LinkedIn",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            LinkedInButtonStandardWidget(
              onTap: () {
                setState(() {
                  user = null;
                  logoutUser = true;
                });
              },
              buttonText: 'Logout',
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('First: ${user?.firstName} '),
                Text('Last: ${user?.lastName} '),
                Text('Email: ${user?.email}'),
                Text('Profile image: ${user?.profileImageUrl}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LinkedInLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
          child: Text('Sign in with LinkedIn'),
          onPressed: () async {
            // Get the client ID and redirect URL
            final String clientId = Constant.Config().clientId;
            final String redirectUrl = Constant.Config().redirectUrl // from config.dart

            String url = 'https://www.linkedin.com/oauth/v2/authorization?'
                'response_type=code&'
                'client_id=$clientId&'
                'redirect_uri=$redirectUrl&'
                'state=random_string&'
                'scope=r_liteprofile%20r_emailaddress';

            // Start the OAuth authentication flow
            final result = await FlutterWebAuth.authenticate(
                url: url, callbackUrlScheme: 'YOUR_APP_SCHEME');

            final code = Uri.parse(result).queryParameters['code'];

            final response = await http.post(
                'YOUR_BACKEND_URL/linkedin/exchange-token', // to be used later during app deployment on a server
                body: {'code': code});

            // Handle the response from the backend
            if (response.statusCode == 200) {
              // Save the access token to use for future requests
              final data = jsonDecode(response.body);
              final accessToken = data['access_token'];
              saveAccessToken(accessToken);

              // Navigate to the home page
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            } else {
              showErrorMessage('Failed to exchange code for access token');
            }
          },
        ),
      ),
    );
  }
}

class AuthCodeObject {
  AuthCodeObject({required this.code, required this.state});

  final String code;
  final String state;
}

class UserObject {
  UserObject({
    this.firstName,
    this.lastName,
    this.email,
    this.profileImageUrl,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profileImageUrl;
}
