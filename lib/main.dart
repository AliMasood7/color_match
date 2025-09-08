import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(const LearningGamesApp());
}

class LearningGamesApp extends StatelessWidget {
  const LearningGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learning Games',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Learning Games"),
        centerTitle: true,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.games,
                size: 80,
                color: Colors.blue[600],
              ),
              const SizedBox(height: 20),
              Text(
                'Choose Your Game',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 30),
              
              // Color Matching Game
              _buildGameButton(
                context,
                'Color Matching',
                'Match colors and learn!',
                Icons.palette,
                Colors.red,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ColorGameScreen()),
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Alphabet Game
              _buildGameButton(
                context,
                'Alphabet Matching',
                'Learn A, B, C letters!',
                Icons.abc,
                Colors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AlphabetGameScreen()),
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Number Game
              _buildGameButton(
                context,
                'Number Counting',
                'Learn 1, 2, 3 numbers!',
                Icons.numbers,
                Colors.orange,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NumberGameScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24),
        label: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class ColorGameScreen extends StatefulWidget {
  const ColorGameScreen({super.key});

  @override
  State<ColorGameScreen> createState() => _ColorGameScreenState();
}

class _ColorGameScreenState extends State<ColorGameScreen> with TickerProviderStateMixin {
  // Game state variables
  int score = 0;
  int level = 1;
  int timeLeft = 60;
  bool gameStarted = false;
  bool gameOver = false;
  Timer? gameTimer;
  Timer? countdownTimer;
  
  // Game data
  List<Color> availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
  ];
  
  List<Color> currentLevelColors = [];
  List<bool> matchedColors = [];
  Color targetColor = Colors.red;
  int targetIndex = 0;
  int currentTargetIndex = 0; // Track which color to match next
  
  // Voice and sound
  FlutterTts flutterTts = FlutterTts();
  AudioPlayer audioPlayer = AudioPlayer();
  bool voiceEnabled = true;
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTTS();
    _setupNewLevel();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _initializeTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  String _getColorName(Color color) {
    if (color == Colors.red) return "Red";
    if (color == Colors.blue) return "Blue";
    if (color == Colors.green) return "Green";
    if (color == Colors.yellow) return "Yellow";
    if (color == Colors.orange) return "Orange";
    if (color == Colors.purple) return "Purple";
    if (color == Colors.pink) return "Pink";
    if (color == Colors.teal) return "Teal";
    return "Unknown";
  }

  void _speakColor(Color color) async {
    if (voiceEnabled) {
      String colorName = _getColorName(color);
      await flutterTts.speak("Find $colorName");
    }
  }

  void _playSuccessSound() async {
    if (voiceEnabled) {
      await flutterTts.speak("Correct! Well done!");
    }
  }

  void _playWrongSound() async {
    if (voiceEnabled) {
      await flutterTts.speak("Try again!");
    }
  }

  void _setupNewLevel() {
    setState(() {
      // Select colors for current level (2 + level colors)
      int numColors = min(2 + level, availableColors.length);
      
      // Shuffle available colors to get random selection
      List<Color> shuffledColors = List.from(availableColors);
      shuffledColors.shuffle();
      
      // Take the required number of colors
      currentLevelColors = shuffledColors.take(numColors).toList();
      matchedColors = List.filled(numColors, false);
      
      // Reset current target index for new level
      currentTargetIndex = 0;
      targetColor = currentLevelColors[currentTargetIndex];
    });
    
    // Announce the first color to find
    _speakColor(targetColor);
  }

  void _startGame() {
    setState(() {
      gameStarted = true;
      gameOver = false;
      score = 0;
      level = 1;
      timeLeft = 60;
    });
    
    _setupNewLevel();
    _startTimer();
  }

  void _startTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) {
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    gameTimer?.cancel();
    setState(() {
      gameOver = true;
      gameStarted = false;
    });
  }

  void _onColorMatched(Color color) {
    int colorIndex = currentLevelColors.indexOf(color);
    if (colorIndex == currentTargetIndex && !matchedColors[colorIndex]) {
      setState(() {
        matchedColors[colorIndex] = true;
        score += 10 * level; // Higher level = more points
      });
      
      _pulseController.forward().then((_) {
        _pulseController.reverse();
      });
      
      _playSuccessSound();
      
      // Move to next color in the level
      _moveToNextColor();
    } else {
      // Wrong color - shake animation
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });
      setState(() {
        score = max(0, score - 5); // Penalty for wrong match
      });
      
      _playWrongSound();
    }
  }

  void _moveToNextColor() {
    // Find next unmatched color
    int nextIndex = -1;
    for (int i = 0; i < currentLevelColors.length; i++) {
      if (!matchedColors[i]) {
        nextIndex = i;
        break;
      }
    }
    
    if (nextIndex != -1) {
      // Move to next color
      setState(() {
        currentTargetIndex = nextIndex;
        targetColor = currentLevelColors[currentTargetIndex];
      });
      
      // Announce next color after a short delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        _speakColor(targetColor);
      });
    } else {
      // All colors matched, move to next level
      Future.delayed(const Duration(milliseconds: 1500), () {
        _nextLevel();
      });
    }
  }

  void _nextLevel() {
    setState(() {
      level++;
      timeLeft += 10; // Bonus time for completing level
    });
    
    // Announce level completion
    if (voiceEnabled) {
      flutterTts.speak("Level $level! Great job!");
    }
    
    _setupNewLevel();
  }

  void _resetGame() {
    gameTimer?.cancel();
    setState(() {
      gameStarted = false;
      gameOver = false;
      score = 0;
      level = 1;
      timeLeft = 60;
    });
    _setupNewLevel();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    countdownTimer?.cancel();
    _pulseController.dispose();
    _shakeController.dispose();
    flutterTts.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Color Matching Game"),
        centerTitle: true,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(voiceEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              setState(() {
                voiceEnabled = !voiceEnabled;
              });
            },
            tooltip: voiceEnabled ? 'Disable Voice' : 'Enable Voice',
          ),
        ],
      ),
      body: gameOver ? _buildGameOverScreen() : _buildGameScreen(),
    );
  }

  Widget _buildGameOverScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events,
              size: 80,
              color: Colors.amber[600],
            ),
            const SizedBox(height: 20),
            Text(
              'Game Over!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Final Score: $score',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Level Reached: $level',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        // Game stats
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.blue[600],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Score', score.toString(), Icons.star, Colors.amber),
              _buildStatCard('Level', level.toString(), Icons.trending_up, Colors.green),
              _buildStatCard('Time', timeLeft.toString(), Icons.timer, Colors.red),
            ],
          ),
        ),
        
        Expanded(
          child: gameStarted ? _buildGameArea() : _buildStartScreen(),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
            ),
            Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.palette,
              size: 80,
              color: Colors.blue[600],
            ),
            const SizedBox(height: 20),
            Text(
              'Color Matching Game',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Match the colored circles to the target color!\n'
              'Drag and drop to play.\n'
              'Complete levels to advance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameArea() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
                     // Target color display
           Container(
             padding: const EdgeInsets.all(10),
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(12),
               boxShadow: [
                 BoxShadow(
                   color: Colors.grey.withOpacity(0.2),
                   spreadRadius: 2,
                   blurRadius: 5,
                   offset: const Offset(0, 2),
                 ),
               ],
             ),
             child: Column(
               children: [
                 Text(
                   'Match This Color:',
                   style: TextStyle(
                     fontSize: 14,
                     fontWeight: FontWeight.w600,
                     color: Colors.grey[700],
                   ),
                 ),
                 const SizedBox(height: 5),
                 Text(
                   _getColorName(targetColor),
                   style: TextStyle(
                     fontSize: 12,
                     fontWeight: FontWeight.bold,
                     color: targetColor,
                   ),
                 ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: targetColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!, width: 2),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 5),
                Text(
                  'Progress: ${matchedColors.where((matched) => matched).length}/${currentLevelColors.length}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
          
          const SizedBox(height: 15),
          
          // Draggable colors
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: currentLevelColors.length,
              itemBuilder: (context, index) {
                return _buildDraggableColor(index);
              },
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Drop target
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: _buildDropTarget(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableColor(int index) {
    Color color = currentLevelColors[index];
    bool isMatched = matchedColors[index];
    
    return Draggable<Color>(
      data: color,
             feedback: Material(
         elevation: 8,
         borderRadius: BorderRadius.circular(50),
         child: Container(
           width: 60,
           height: 60,
           decoration: BoxDecoration(
             color: color,
             shape: BoxShape.circle,
             border: Border.all(color: Colors.white, width: 2),
           ),
         ),
       ),
      childWhenDragging: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[400]!, width: 2),
        ),
        child: Icon(
          Icons.drag_indicator,
          color: Colors.grey[600],
          size: 24,
        ),
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isMatched ? Colors.grey[300] : color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isMatched ? Colors.grey[400]! : Colors.white,
            width: 3,
          ),
        ),
        child: isMatched
            ? Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 30,
              )
            : null,
      ),
    );
  }

  Widget _buildDropTarget() {
    return DragTarget<Color>(
      onAccept: (color) {
        _onColorMatched(color);
      },
      builder: (context, candidateData, rejectedData) {
        bool isHovering = candidateData.isNotEmpty;
        
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isHovering ? Colors.blue[100] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovering ? Colors.blue : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 24,
                color: isHovering ? Colors.blue : Colors.grey[600],
              ),
              const SizedBox(height: 3),
              Text(
                isHovering ? 'Drop!' : 'Drop',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isHovering ? Colors.blue : Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Alphabet Game Screen
class AlphabetGameScreen extends StatefulWidget {
  const AlphabetGameScreen({super.key});

  @override
  State<AlphabetGameScreen> createState() => _AlphabetGameScreenState();
}

class _AlphabetGameScreenState extends State<AlphabetGameScreen> with TickerProviderStateMixin {
  // Game state variables
  int score = 0;
  int level = 1;
  int timeLeft = 60;
  bool gameStarted = false;
  bool gameOver = false;
  Timer? gameTimer;
  
  // Game data
  List<String> availableLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  List<String> currentLevelLetters = [];
  List<bool> matchedLetters = [];
  String targetLetter = 'A';
  int currentTargetIndex = 0;
  
  // Voice and sound
  FlutterTts flutterTts = FlutterTts();
  bool voiceEnabled = true;
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTTS();
    _setupNewLevel();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _initializeTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  void _speakLetter(String letter) async {
    if (voiceEnabled) {
      await flutterTts.speak("Find letter $letter");
    }
  }

  void _playSuccessSound() async {
    if (voiceEnabled) {
      await flutterTts.speak("Correct! Well done!");
    }
  }

  void _playWrongSound() async {
    if (voiceEnabled) {
      await flutterTts.speak("Try again!");
    }
  }

  void _setupNewLevel() {
    setState(() {
      int numLetters = min(2 + level, availableLetters.length);
      List<String> shuffledLetters = List.from(availableLetters);
      shuffledLetters.shuffle();
      
      currentLevelLetters = shuffledLetters.take(numLetters).toList();
      matchedLetters = List.filled(numLetters, false);
      
      currentTargetIndex = 0;
      targetLetter = currentLevelLetters[currentTargetIndex];
    });
    
    _speakLetter(targetLetter);
  }

  void _startGame() {
    setState(() {
      gameStarted = true;
      gameOver = false;
      score = 0;
      level = 1;
      timeLeft = 60;
    });
    
    _setupNewLevel();
    _startTimer();
  }

  void _startTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) {
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    gameTimer?.cancel();
    setState(() {
      gameOver = true;
      gameStarted = false;
    });
  }

  void _onLetterMatched(String letter) {
    int letterIndex = currentLevelLetters.indexOf(letter);
    if (letterIndex == currentTargetIndex && !matchedLetters[letterIndex]) {
      setState(() {
        matchedLetters[letterIndex] = true;
        score += 10 * level;
      });
      
      _pulseController.forward().then((_) {
        _pulseController.reverse();
      });
      
      _playSuccessSound();
      _moveToNextLetter();
    } else {
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });
      setState(() {
        score = max(0, score - 5);
      });
      
      _playWrongSound();
    }
  }

  void _moveToNextLetter() {
    int nextIndex = -1;
    for (int i = 0; i < currentLevelLetters.length; i++) {
      if (!matchedLetters[i]) {
        nextIndex = i;
        break;
      }
    }
    
    if (nextIndex != -1) {
      setState(() {
        currentTargetIndex = nextIndex;
        targetLetter = currentLevelLetters[currentTargetIndex];
      });
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        _speakLetter(targetLetter);
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _nextLevel();
      });
    }
  }

  void _nextLevel() {
    setState(() {
      level++;
      timeLeft += 10;
    });
    
    if (voiceEnabled) {
      flutterTts.speak("Level $level! Great job!");
    }
    
    _setupNewLevel();
  }

  void _resetGame() {
    gameTimer?.cancel();
    setState(() {
      gameStarted = false;
      gameOver = false;
      score = 0;
      level = 1;
      timeLeft = 60;
    });
    _setupNewLevel();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _pulseController.dispose();
    _shakeController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Alphabet Matching"),
        centerTitle: true,
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(voiceEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              setState(() {
                voiceEnabled = !voiceEnabled;
              });
            },
            tooltip: voiceEnabled ? 'Disable Voice' : 'Enable Voice',
          ),
        ],
      ),
      body: gameOver ? _buildGameOverScreen() : _buildGameScreen(),
    );
  }

  Widget _buildGameOverScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events,
              size: 80,
              color: Colors.amber[600],
            ),
            const SizedBox(height: 20),
            Text(
              'Game Over!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Final Score: $score',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Level Reached: $level',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        // Game stats
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.green[600],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Score', score.toString(), Icons.star, Colors.amber),
              _buildStatCard('Level', level.toString(), Icons.trending_up, Colors.white),
              _buildStatCard('Time', timeLeft.toString(), Icons.timer, Colors.red),
            ],
          ),
        ),
        
        Expanded(
          child: gameStarted ? _buildGameArea() : _buildStartScreen(),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.abc,
              size: 80,
              color: Colors.green[600],
            ),
            const SizedBox(height: 20),
            Text(
              'Alphabet Matching Game',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Match the letters to the target letter!\n'
              'Drag and drop to play.\n'
              'Learn A, B, C and more!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameArea() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Target letter display
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Match This Letter:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  targetLetter,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green[300]!, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            targetLetter,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 5),
                Text(
                  'Progress: ${matchedLetters.where((matched) => matched).length}/${currentLevelLetters.length}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Draggable letters
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: currentLevelLetters.length,
              itemBuilder: (context, index) {
                return _buildDraggableLetter(index);
              },
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Drop target
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: _buildDropTarget(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableLetter(int index) {
    String letter = currentLevelLetters[index];
    bool isMatched = matchedLetters[index];
    
    return Draggable<String>(
      data: letter,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.green[100],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green[300]!, width: 2),
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[400]!, width: 2),
        ),
        child: Icon(
          Icons.drag_indicator,
          color: Colors.grey[600],
          size: 24,
        ),
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isMatched ? Colors.grey[300] : Colors.green[100],
          shape: BoxShape.circle,
          border: Border.all(
            color: isMatched ? Colors.grey[400]! : Colors.green[300]!,
            width: 3,
          ),
        ),
        child: isMatched
            ? Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 30,
              )
            : Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDropTarget() {
    return DragTarget<String>(
      onAccept: (letter) {
        _onLetterMatched(letter);
      },
      builder: (context, candidateData, rejectedData) {
        bool isHovering = candidateData.isNotEmpty;
        
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isHovering ? Colors.green[100] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovering ? Colors.green : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 24,
                color: isHovering ? Colors.green : Colors.grey[600],
              ),
              const SizedBox(height: 3),
              Text(
                isHovering ? 'Drop!' : 'Drop',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isHovering ? Colors.green : Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Number Game Screen
class NumberGameScreen extends StatefulWidget {
  const NumberGameScreen({super.key});

  @override
  State<NumberGameScreen> createState() => _NumberGameScreenState();
}

class _NumberGameScreenState extends State<NumberGameScreen> with TickerProviderStateMixin {
  // Game state variables
  int score = 0;
  int level = 1;
  int timeLeft = 60;
  bool gameStarted = false;
  bool gameOver = false;
  Timer? gameTimer;
  
  // Game data
  List<int> availableNumbers = [1, 2, 3, 4, 5, 6, 7, 8];
  List<int> currentLevelNumbers = [];
  List<bool> matchedNumbers = [];
  int targetNumber = 1;
  int currentTargetIndex = 0;
  
  // Voice and sound
  FlutterTts flutterTts = FlutterTts();
  bool voiceEnabled = true;
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTTS();
    _setupNewLevel();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _initializeTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  String _getNumberName(int number) {
    switch (number) {
      case 1: return "One";
      case 2: return "Two";
      case 3: return "Three";
      case 4: return "Four";
      case 5: return "Five";
      case 6: return "Six";
      case 7: return "Seven";
      case 8: return "Eight";
      default: return "Unknown";
    }
  }

  void _speakNumber(int number) async {
    if (voiceEnabled) {
      String numberName = _getNumberName(number);
      await flutterTts.speak("Find number $numberName");
    }
  }

  void _playSuccessSound() async {
    if (voiceEnabled) {
      await flutterTts.speak("Correct! Well done!");
    }
  }

  void _playWrongSound() async {
    if (voiceEnabled) {
      await flutterTts.speak("Try again!");
    }
  }

  void _setupNewLevel() {
    setState(() {
      int numNumbers = min(2 + level, availableNumbers.length);
      List<int> shuffledNumbers = List.from(availableNumbers);
      shuffledNumbers.shuffle();
      
      currentLevelNumbers = shuffledNumbers.take(numNumbers).toList();
      matchedNumbers = List.filled(numNumbers, false);
      
      currentTargetIndex = 0;
      targetNumber = currentLevelNumbers[currentTargetIndex];
    });
    
    _speakNumber(targetNumber);
  }

  void _startGame() {
    setState(() {
      gameStarted = true;
      gameOver = false;
      score = 0;
      level = 1;
      timeLeft = 60;
    });
    
    _setupNewLevel();
    _startTimer();
  }

  void _startTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) {
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    gameTimer?.cancel();
    setState(() {
      gameOver = true;
      gameStarted = false;
    });
  }

  void _onNumberMatched(int number) {
    int numberIndex = currentLevelNumbers.indexOf(number);
    if (numberIndex == currentTargetIndex && !matchedNumbers[numberIndex]) {
      setState(() {
        matchedNumbers[numberIndex] = true;
        score += 10 * level;
      });
      
      _pulseController.forward().then((_) {
        _pulseController.reverse();
      });
      
      _playSuccessSound();
      _moveToNextNumber();
    } else {
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });
      setState(() {
        score = max(0, score - 5);
      });
      
      _playWrongSound();
    }
  }

  void _moveToNextNumber() {
    int nextIndex = -1;
    for (int i = 0; i < currentLevelNumbers.length; i++) {
      if (!matchedNumbers[i]) {
        nextIndex = i;
        break;
      }
    }
    
    if (nextIndex != -1) {
      setState(() {
        currentTargetIndex = nextIndex;
        targetNumber = currentLevelNumbers[currentTargetIndex];
      });
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        _speakNumber(targetNumber);
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _nextLevel();
      });
    }
  }

  void _nextLevel() {
    setState(() {
      level++;
      timeLeft += 10;
    });
    
    if (voiceEnabled) {
      flutterTts.speak("Level $level! Great job!");
    }
    
    _setupNewLevel();
  }

  void _resetGame() {
    gameTimer?.cancel();
    setState(() {
      gameStarted = false;
      gameOver = false;
      score = 0;
      level = 1;
      timeLeft = 60;
    });
    _setupNewLevel();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _pulseController.dispose();
    _shakeController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Number Counting"),
        centerTitle: true,
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(voiceEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              setState(() {
                voiceEnabled = !voiceEnabled;
              });
            },
            tooltip: voiceEnabled ? 'Disable Voice' : 'Enable Voice',
          ),
        ],
      ),
      body: gameOver ? _buildGameOverScreen() : _buildGameScreen(),
    );
  }

  Widget _buildGameOverScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events,
              size: 80,
              color: Colors.amber[600],
            ),
            const SizedBox(height: 20),
            Text(
              'Game Over!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Final Score: $score',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Level Reached: $level',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        // Game stats
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.orange[600],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Score', score.toString(), Icons.star, Colors.amber),
              _buildStatCard('Level', level.toString(), Icons.trending_up, Colors.white),
              _buildStatCard('Time', timeLeft.toString(), Icons.timer, Colors.red),
            ],
          ),
        ),
        
        Expanded(
          child: gameStarted ? _buildGameArea() : _buildStartScreen(),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.numbers,
              size: 80,
              color: Colors.orange[600],
            ),
            const SizedBox(height: 20),
            Text(
              'Number Counting Game',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.orange[600],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Match the numbers to the target number!\n'
              'Drag and drop to play.\n'
              'Learn 1, 2, 3 and more!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameArea() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Target number display
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Match This Number:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _getNumberName(targetNumber),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[600],
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orange[300]!, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            targetNumber.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 5),
                Text(
                  'Progress: ${matchedNumbers.where((matched) => matched).length}/${currentLevelNumbers.length}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Draggable numbers
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: currentLevelNumbers.length,
              itemBuilder: (context, index) {
                return _buildDraggableNumber(index);
              },
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Drop target
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: _buildDropTarget(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableNumber(int index) {
    int number = currentLevelNumbers[index];
    bool isMatched = matchedNumbers[index];
    
    return Draggable<int>(
      data: number,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.orange[100],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange[300]!, width: 2),
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[400]!, width: 2),
        ),
        child: Icon(
          Icons.drag_indicator,
          color: Colors.grey[600],
          size: 24,
        ),
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isMatched ? Colors.grey[300] : Colors.orange[100],
          shape: BoxShape.circle,
          border: Border.all(
            color: isMatched ? Colors.grey[400]! : Colors.orange[300]!,
            width: 3,
          ),
        ),
        child: isMatched
            ? Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 30,
              )
            : Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDropTarget() {
    return DragTarget<int>(
      onAccept: (number) {
        _onNumberMatched(number);
      },
      builder: (context, candidateData, rejectedData) {
        bool isHovering = candidateData.isNotEmpty;
        
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isHovering ? Colors.orange[100] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovering ? Colors.orange : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 24,
                color: isHovering ? Colors.orange : Colors.grey[600],
              ),
              const SizedBox(height: 3),
              Text(
                isHovering ? 'Drop!' : 'Drop',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isHovering ? Colors.orange : Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}