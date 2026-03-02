import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../pages/chat_list_page.dart';
import '../pages/payments_page.dart';
import '../pages/product_search_page.dart';
import '../pages/profile_page.dart';
import '../../../contacts/presentation/pages/contacts_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _hasCheckedTwoStep = false;

  final List<Widget> _pages = [
    const ChatListPage(),
    const ContactsPage(),
    const PaymentsPage(),
    const ProductSearchPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkTwoStepVerification();
  }

  Future<void> _checkTwoStepVerification() async {
    // For now, we'll skip two-step verification in development
    // In production, you would check if the user has completed two-step verification
    setState(() {
      _hasCheckedTwoStep = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasCheckedTwoStep) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts_outlined),
            activeIcon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            activeIcon: Icon(Icons.payment),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
