import 'package:aurelle_flutter/core/navigation/appRouter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_responsive_builder/the_responsive_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  runApp(
    ProviderScope(
      child: TheResponsiveBuilder(
        builder: (context, orientation, screenType) => const AurelleAPP(),
      ),
    ),
  );
}

class AurelleAPP extends ConsumerStatefulWidget {
  
  const AurelleAPP({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AurelleAPPState();
}

class _AurelleAPPState extends ConsumerState<AurelleAPP> {

  @override
  Widget build(BuildContext context) {
        final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Aurelle',
      debugShowCheckedModeBanner: false,
 
      // ── Theme ─────────────────────────────────────────────────────────────
      // theme: 
 
      // ── Router ────────────────────────────────────────────────────────────
      routerConfig: router,
    );
}
}
