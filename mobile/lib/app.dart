import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/phone_verification_page.dart';
import 'features/auth/presentation/pages/otp_verification_page.dart';
import 'features/auth/presentation/pages/two_step_verification_page.dart';
import 'features/main/presentation/pages/main_navigation.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/chat/presentation/pages/new_conversation_page.dart';
import 'features/chat/presentation/pages/chat_conversation_page.dart';
import 'features/contacts/presentation/pages/contact_invitation_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Let's Talk",
      theme: Theme.of(context),
      home: const SplashPage(),
      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/phone-verification': (context) => const PhoneVerificationPage(),
        '/otp-verification': (context) => const OTPVerificationPage(),
        '/two-step-verification': (context) => const TwoStepVerificationPage(),
        '/main': (context) => const MainNavigation(),
        '/new-conversation': (context) => const NewConversationPage(),
        '/chat-conversation': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          final chat = args?['chat'];
          return ChatConversationPage(chat: chat);
        },
        '/contact-invitation': (context) => const ContactInvitationPage(),
      },
    );
  }
}
