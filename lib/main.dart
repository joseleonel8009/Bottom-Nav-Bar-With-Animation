import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainBounceButtomNavBar(),
    );
  }
}

class MainBounceButtomNavBar extends StatefulWidget {
  @override
  _MainBounceButtomNavBarState createState() => _MainBounceButtomNavBarState();
}

class _MainBounceButtomNavBarState extends State<MainBounceButtomNavBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        // Paginas en las que va cambiando
        children: [
          // Pantalla 1 de ejemplo
          Container(
            color: Colors.amber,
            child: Center(
              child: Text("1"),
            ),
          ),
          // Pantalla 2 de ejemplo
          Container(
            color: Colors.red,
            child: Center(
              child: Text("2"),
            ),
          ),
          // Pantalla 3 de ejemplo
          Container(
            color: Colors.blue,
            child: Center(
              child: Text("3"),
            ),
          ),
          // Pantalla 4 de ejemplo
          Container(
            color: Colors.redAccent,
            child: Center(
              child: Text("4"),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BounceNavBar(
        initialIndex: 0,
        // bgColor: Colors.white,
        items: [
          Icon(
            Icons.ac_unit,
            color: Colors.white,
          ),
          Icon(
            Icons.account_box,
            color: Colors.white,
          ),
          Icon(
            Icons.access_alarms,
            color: Colors.white,
          ),
          Icon(
            Icons.accessibility_new,
            color: Colors.white,
          ),
        ],
        onTab: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class BounceNavBar extends StatefulWidget {
  final Color bgColor;
  final List<Widget> items;
  final Function onTab;
  final int initialIndex;
  final double movement;

  const BounceNavBar({
    Key key,
    this.bgColor = Colors.green,
    @required this.items,
    @required this.onTab,
    this.initialIndex = 0,
    this.movement = 75.0,
  }) : super(key: key);

  @override
  _BounceNavBarState createState() => _BounceNavBarState();
}

class _BounceNavBarState extends State<BounceNavBar>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animNavBarIn;
  Animation _animNavBarOut;
  Animation _animCircleItem;
  Animation _animElevationIn;
  Animation _animElevationOut;

  int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 1200,
      ),
    );

    _animNavBarIn = CurveTween(
      curve: Interval(
        0.1,
        0.6,
        curve: Curves.decelerate,
      ),
    ).animate(_controller);

    _animNavBarOut = CurveTween(
      curve: Interval(
        0.6,
        1.0,
        curve: Curves.bounceOut,
      ),
    ).animate(_controller);

    _animCircleItem = CurveTween(
      curve: Interval(
        0.0,
        0.5,
      ),
    ).animate(_controller);

    _animElevationIn = CurveTween(
      curve: Interval(
        0.3,
        0.5,
        curve: Curves.decelerate,
      ),
    ).animate(_controller);

    _animElevationOut = CurveTween(
      curve: Interval(
        0.55,
        1.0,
        curve: Curves.bounceOut,
      ),
    ).animate(_controller);

    _controller.forward(from: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double currentWidth = width;
    double currentElevation = 0.0;
    final movement = widget.movement;
    return SizedBox(
      height: kBottomNavigationBarHeight,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          currentWidth = width -
              (movement * _animNavBarIn.value) +
              (movement * _animNavBarOut.value);
          currentElevation = -movement * _animElevationIn.value +
              (movement - kBottomNavigationBarHeight / 4) *
                  _animElevationOut.value;
          return Center(
            child: Container(
              width: currentWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                color: widget.bgColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  widget.items.length,
                  (index) {
                    final child = widget.items[index];
                    final innerWidget = CircleAvatar(
                      radius: 30.0,
                      backgroundColor: widget.bgColor,
                      child: child,
                    );
                    if (index == _currentIndex) {
                      return Expanded(
                        child: CustomPaint(
                          painter: _CircleItemPainter(
                            _animCircleItem.value,
                          ),
                          child: Transform.translate(
                            offset: Offset(0.0, currentElevation),
                            child: innerWidget,
                          ),
                        ),
                      );
                    } else {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            widget.onTab(index);
                            setState(() {
                              _currentIndex = index;
                            });
                            _controller.forward(from: 0.0);
                          },
                          child: innerWidget,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CircleItemPainter extends CustomPainter {
  final double progress;

  _CircleItemPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 20.0 * progress;
    final strokeWidth = 10.0;
    final currentStrokeWidth = strokeWidth * (1 - progress);
    if (progress < 1) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = currentStrokeWidth,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
