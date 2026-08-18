import 'package:flutter/material.dart';

class EmnLogo extends StatelessWidget {
  const EmnLogo({super.key, this.size = 120});

  final double size;

  static const Color _navy = Color(0xFF0D1B4E);
  static const Color _gold = Color(0xFFF5C400);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.2),
        border: Border.all(color: _navy, width: size * 0.03),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x55000000), blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.17),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size * 0.06, vertical: size * 0.14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(height: size * 0.04, color: _navy),
              Container(height: size * 0.024, color: _gold),
              SizedBox(height: size * 0.04),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'EMN PLANT',
                  style: TextStyle(
                    fontSize: size * 0.155,
                    fontWeight: FontWeight.w900,
                    color: _navy,
                    letterSpacing: size * 0.016,
                  ),
                ),
              ),
              SizedBox(height: size * 0.04),
              Container(height: size * 0.024, color: _gold),
              Container(height: size * 0.04, color: _navy),
            ],
          ),
        ),
      ),
    );
  }
}
