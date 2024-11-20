import 'package:flutter/material.dart';

class CustomDropdownMenu extends StatelessWidget {
  final List<CustomDropdownMenuItem> items;

  const CustomDropdownMenu({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return _DropdownMenuHeader(
      onTap: (index) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        final offset = renderBox.localToGlobal(renderBox.paintBounds.topLeft);
        final rect = offset & renderBox.paintBounds.size;
        Navigator.of(context).push(_DropdownMenuRoute(
          targetRect: rect,
          builder: (context, animation) => _DropdownMenuBody(
            animation: animation,
            headerRect: rect,
            items: items,
            currentIndex: index,
          ),
        ));
      },
      items: items,
    );
  }
}

class CustomDropdownMenuItem {
  final String header;
  final Widget? body;

  const CustomDropdownMenuItem({
    required this.header,
    this.body,
  });
}

class _DropdownMenuHeader extends StatelessWidget {
  final List<CustomDropdownMenuItem> items;
  final int? currentIndex;
  final void Function(int index)? onTap;

  const _DropdownMenuHeader({
    required this.items,
    this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ws = <Widget>[];
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      final isActive = currentIndex == index;
      if (index != 0) ws.add(const SizedBox(width: 5));
      ws.add(Expanded(
        child: GestureDetector(
          onTap: () => onTap?.call(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: const ShapeDecoration(
              shape: StadiumBorder(),
              color: Color(0xFFF5F6F7),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    item.header,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: isActive
                          ? const Color(0xFFFF0000)
                          : const Color(0xFF333333),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                // Icon(
                //   CupertinoIcons.chevron_down,
                //   color: isActive
                //       ? const Color(0xFFFF0000)
                //       : const Color(0xFF979797),
                //   size: 12,
                // ),
              ],
            ),
          ),
        ),
      ));
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(children: ws),
    );
  }
}

class _DropdownMenuBody extends StatefulWidget {
  final int currentIndex;
  final List<CustomDropdownMenuItem> items;
  final Rect headerRect;
  final Animation<double> animation;

  const _DropdownMenuBody({
    required this.currentIndex,
    required this.items,
    required this.animation,
    required this.headerRect,
  });

  @override
  State<_DropdownMenuBody> createState() => _DropdownMenuBodyState();
}

class _DropdownMenuBodyState extends State<_DropdownMenuBody> {
  int _currentIndex = 0;

  @override
  void initState() {
    _currentIndex = widget.currentIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            child: SlideTransition(
              position: widget.animation.drive(Tween(
                begin: const Offset(0, -1),
                end: const Offset(0, 0),
              )),
              child: Container(
                clipBehavior: Clip.hardEdge,
                padding: EdgeInsets.only(top: widget.headerRect.height),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(10),
                  ),
                ),
                child: widget.items[_currentIndex].body,
              ),
            ),
          ),
          _DropdownMenuHeader(
            currentIndex: _currentIndex,
            items: widget.items,
            onTap: (index) {
              if (_currentIndex == index) {
                Navigator.of(context).pop();
                return;
              }
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _DropdownMenuRoute extends PopupRoute<void> {
  final Rect targetRect;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
  ) builder;

  _DropdownMenuRoute({
    required this.targetRect,
    required this.builder,
  });

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dropdown menu';

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          top: targetRect.bottom,
          child: GestureDetector(
            onTap: Navigator.of(context).pop,
            child: ColoredBox(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
        Positioned(
          left: targetRect.left,
          width: targetRect.right - targetRect.left,
          top: targetRect.top,
          bottom: 0,
          child: builder(context, animation),
        ),
      ],
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (!animation.isCompleted) {
      return AbsorbPointer(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              top: targetRect.bottom,
              child: FadeTransition(
                opacity: animation,
                child: ColoredBox(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            Positioned(
              left: targetRect.left,
              width: targetRect.right - targetRect.left,
              top: targetRect.top,
              bottom: 0,
              child: builder(context, animation),
            ),
          ],
        ),
      );
    }
    return child;
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);
}
