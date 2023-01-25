import 'package:flutter/material.dart';
import 'package:linkedin_login/linkedin_login.dart';

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
