import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '/app/domain/services/network/service.dart';
import '/modules/auth/data/repository.dart';
import '/modules/auth/data/sources/local.dart';
import '/modules/auth/domain/service.dart';

class AuthModule extends StatelessWidget {
  const AuthModule({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (context) => AuthService(
            networkService: context.read<NetworkService>(),
            repository: const AuthRepository(
              local: LocalAuthDataSource(),
            ),
          ),
        ),
      ],
      child: child,
    );
  }
}
