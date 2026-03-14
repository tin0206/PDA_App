import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? selectedUser;
  String pin = '';
  bool _isAuthenticating = false;

  final List<Map<String, String?>> users = [
    {
      'name': 'Nguyễn Văn An',
      'role': 'Giám sát ca - ID: 8942',
      'avatar': 'assets/avatar1.png',
    },
    {
      'name': 'Trần Thị Bình',
      'role': 'Kiểm soát chất lượng - ID: 4421',
      'avatar': 'assets/avatar2.png',
    },
    {
      'name': 'Lê Minh Cường',
      'role': 'Vận hành dây chuyền - ID: 1190',
      'avatar': 'assets/avatar3.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (users.isNotEmpty) {
      selectedUser = users[0]['name'];
    }
  }

  String _currentShiftBadge() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 14) return 'Ca 1 - 06:00-14:00';
    if (hour >= 14 && hour < 22) return 'Ca 2 - 14:00-22:00';
    return 'Ca 3 - 22:00-06:00';
  }

  Future<void> _submitPin() async {
    if (_isAuthenticating) return;
    _isAuthenticating = true;

    const correctPin = '1111';
    if (pin == correctPin) {
      final selectedMap = users.firstWhere(
        (u) => u['name'] == selectedUser,
        orElse: () => {'name': selectedUser},
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DashboardScreen(user: selectedMap)),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mã PIN không đúng')));
      setState(() => pin = '');
    }

    _isAuthenticating = false;
  }

  void _onDigitTap(String digit) {
    if (pin.length >= 4) return;
    setState(() {
      pin += digit;
    });
    if (pin.length == 4) {
      Future.microtask(_submitPin);
    }
  }

  void _onBackspaceTap() {
    if (pin.isEmpty) return;
    setState(() {
      pin = pin.substring(0, pin.length - 1);
    });
  }

  void _onClearTap() {
    if (pin.isEmpty) return;
    setState(() {
      pin = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              Expanded(child: _buildUserSelection()),
              const SizedBox(height: 12),
              if (selectedUser != null) ...[
                _buildPinEntry(),
                const SizedBox(height: 12),
                _buildNumpad(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.factory, color: Colors.white),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masan MMB',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text('Sản xuất', style: TextStyle(color: Colors.grey)),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.circle, color: Colors.green, size: 10),
              SizedBox(width: 6),
              Text(
                'TRỰC TUYẾN',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CHỌN NGƯỜI VẬN HÀNH',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _currentShiftBadge(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...users.map(_buildUserTile),
                const SizedBox(height: 8),
                _buildGuestLogin(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTile(Map<String, String?> user) {
    final isSelected = selectedUser == (user['name'] ?? '');
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedUser = user['name'];
          pin = '';
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            const CircleAvatar(backgroundColor: Colors.grey, radius: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user['role'] ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blue)
            else
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestLogin() {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: const Radius.circular(12),
        dashPattern: const [8, 3],
        strokeWidth: 2,
        strokeCap: StrokeCap.round,
        color: Colors.grey.withValues(alpha: 0.5),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_rounded, color: Colors.grey, size: 20),
              SizedBox(width: 8),
              Text(
                'Đăng nhập khách',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinEntry() {
    return Column(
      children: [
        Text(
          selectedUser ?? 'Người dùng',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                index < pin.length ? Icons.circle : Icons.circle_outlined,
                color: index < pin.length ? Colors.blue : Colors.grey,
                size: 16,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNumpad() {
    return SizedBox(
      height: 220,
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.5,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ...List.generate(9, (index) => _buildNumpadButton('${index + 1}')),
          _buildNumpadButton('X', isIcon: true, iconData: Icons.backspace),
          _buildNumpadButton('0'),
          _buildNumpadButton('C', isIcon: true, iconData: Icons.close),
        ],
      ),
    );
  }

  Widget _buildNumpadButton(
    String text, {
    bool isIcon = false,
    IconData? iconData,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.blue.withValues(alpha: 0.3),
        highlightColor: Colors.blue.withValues(alpha: 0.15),
        onTap: () {
          if (isIcon) {
            if (text == 'X') {
              _onBackspaceTap();
            } else {
              _onClearTap();
            }
            return;
          }
          _onDigitTap(text);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: isIcon
                ? Icon(iconData ?? Icons.close, color: Colors.red, size: 20)
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
