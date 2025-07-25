import 'package:flutter/material.dart';

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({Key? key}) : super(key: key);

  @override
  _OrderStatusPageState createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage>
    with SingleTickerProviderStateMixin {
  int currentStep = 0; // 0=Received, 1=Preparing, 2=Ready for Pickup
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/UserMainBackground.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.01),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                      ),
                      child: Image.asset(
                        'assets/image/BackButton.jpg',
                        width: screenWidth * 0.1,
                        height: screenWidth * 0.1,
                      ),
                    ),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Expanded(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.35),
                        child: Image.asset(
                          'assets/image/chef.png',
                          width: screenWidth * 0.8,
                          height: screenWidth * 0.8,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: screenHeight * 0.35,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Received',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.075,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Text(
                                  '12:00 – 12:15 PM',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Row(
                                  children: [
                                    _buildStepIcon(
                                      Icons.list_alt,
                                      0,
                                      screenWidth,
                                    ),
                                    _buildLine(0),
                                    _buildStepIcon(
                                      Icons.restaurant,
                                      1,
                                      screenWidth,
                                    ),
                                    _buildLine(1),
                                    _buildStepIcon(
                                      Icons.check_circle_outline,
                                      2,
                                      screenWidth,
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.03),
                                Text(
                                  'Order Detail',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.07,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  '1 item\nx1 Pearl milk tea',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.06,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => currentStep = 1),
                      child: Text(
                        "Receive",
                        style: TextStyle(fontSize: screenWidth * 0.045),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => currentStep = 2),
                      child: Text(
                        "Complete",
                        style: TextStyle(fontSize: screenWidth * 0.045),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLine(int index) {
    bool isCompleted = index < currentStep;
    bool isCurrent = index == currentStep;

    return Expanded(
      child:
          isCurrent
              ? _buildAnimatedShimmerLine()
              : AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 4,
                color: isCompleted ? Colors.green : Colors.black,
              ),
    );
  }

  Widget _buildAnimatedShimmerLine() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.withOpacity(0.3),
                Colors.green,
                Colors.green.withOpacity(0.3),
              ],
              stops: [
                (_shimmerController.value - 0.2).clamp(0.0, 1.0),
                _shimmerController.value,
                (_shimmerController.value + 0.2).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepIcon(IconData icon, int stepIndex, double screenWidth) {
    bool isCompleted = stepIndex <= currentStep;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: EdgeInsets.all(screenWidth * 0.015),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green : Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Icon(
        icon,
        color: isCompleted ? Colors.white : Colors.black,
        size: screenWidth * 0.09,
      ),
    );
  }
}
