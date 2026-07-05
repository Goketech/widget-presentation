import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const SliderApp());
}

class SliderApp extends StatelessWidget {
  const SliderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product Carousel',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF3F6FF),
        useMaterial3: true,
      ),
      home: const CarouselPage(),
    );
  }
}

class CarouselPage extends StatelessWidget {
  const CarouselPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Swipe to browse products →',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            const SmoothProductCarousel(
              itemCount: 5,
              autoScrollDuration: Duration(seconds: 8),
              snapDuration: Duration(milliseconds: 400),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductItem {
  final String id;
  final String name;
  final String price;
  final Color color;

  _ProductItem({
    required this.id,
    required this.name,
    required this.price,
    required this.color,
  });
}

class SmoothProductCarousel extends StatefulWidget {
  const SmoothProductCarousel({
    super.key,
    required this.itemCount,
    this.autoScrollDuration = const Duration(seconds: 6),
    this.snapDuration = const Duration(milliseconds: 400),
  });

  final int itemCount;
  final Duration autoScrollDuration;
  final Duration snapDuration;

  @override
  State<SmoothProductCarousel> createState() => _SmoothProductCarouselState();
}

class _SmoothProductCarouselState extends State<SmoothProductCarousel>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final Timer _autoScrollTimer;
  int _currentIndex = 0;
  late List<_ProductItem> _products;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.75,
    );

    _products = List.generate(
      widget.itemCount,
      (index) => _ProductItem(
        id: 'product_$index',
        name: 'Premium Product ${index + 1}',
        price: '\$${(99 + index * 20).toStringAsFixed(2)}',
        color: [
          const Color(0xFF00C6FF),
          const Color(0xFF0072FF),
          const Color(0xFF8E2DE2),
          const Color(0xFFFF4E50),
          const Color(0xFF43E97B),
        ][index % 5],
      ),
    );

    _autoScrollTimer = Timer.periodic(widget.autoScrollDuration, (_) {
      if (_pageController.hasClients) {
        final nextPage = (_currentIndex + 1) % widget.itemCount;
        _pageController.animateToPage(
          nextPage,
          duration: widget.snapDuration,
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemCount: widget.itemCount,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildProductCard(_products[index], index);
            },
          ),
        ),
        const SizedBox(height: 24),
        _buildPaginationIndicators(),
      ],
    );
  }

  Widget _buildProductCard(_ProductItem product, int index) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to cart!'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1200),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _pageController,
        builder: (context, child) {
          double value = 0.0;
          if (_pageController.hasClients && _pageController.position.hasContentDimensions) {
            value = index - _pageController.page!;
            value = (value * 0.038).clamp(-1, 1);
          }

          return Transform.scale(
            scale: 1 - value.abs() * 0.1,
            child: Opacity(
              opacity: (1 - value.abs() * 0.5).clamp(0.5, 1.0),
              child: child,
            ),
          );
        },
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: product.color.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          product.color,
                          product.color.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          child: Icon(
                            Icons.shopping_bag_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          product.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          product.price,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: const Text(
                            'Tap to Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.itemCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: _currentIndex == index ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentIndex == index
                ? const Color(0xFF8E2DE2)
                : const Color(0xFF8E2DE2).withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}