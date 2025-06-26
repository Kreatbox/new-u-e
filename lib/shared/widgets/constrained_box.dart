import 'package:flutter/material.dart';
import 'package:universal_exam/shared/widgets/container.dart';

class CustomConstrainedBox extends StatelessWidget {
  final String title;
  final Widget child;

  const CustomConstrainedBox({
    super.key,
    required this.title,
    required this.child,
  });

  static const _boxConstraints = BoxConstraints(
    minWidth: 400,
    maxWidth: 600,
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: _boxConstraints,
            child: CustomContainer(
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
