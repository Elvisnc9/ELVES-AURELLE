import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {

  @override
  Widget build(BuildContext context) {
    return Center(child: 
    Text('SHOP SCREEN'),);
  }
}