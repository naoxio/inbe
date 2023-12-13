import 'package:flutter/material.dart';
import 'package:inner_breeze/utils/audio_player_service.dart';

class AnimatedCircle extends StatefulWidget {

  final int volume;
  final Duration tempoDuration; 
  final String? innerText; 
  final Function()? controlCallback;

  AnimatedCircle({
    Key? key,
    required this.volume,
    required this.tempoDuration,
    this.innerText,
    this.controlCallback
  }) : super(key: key); 
  
  @override
  AnimatedCircleState createState() => AnimatedCircleState();
}

class AnimatedCircleState extends State<AnimatedCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  AudioPlayerService audioPlayerService = AudioPlayerService();

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.tempoDuration,
    );
    _radiusAnimation = Tween<double>(begin: 40, end: 72).animate(_controller);
    audioPlayerService.initialize().then((_) {
      _controller.addStatusListener((status) {
        try {
          Duration newDuration = widget.tempoDuration;
          if (_controller.duration != newDuration &&
              _controller.status == AnimationStatus.forward) {
            _stopAudio();
            _controller.stop();
            _controller.duration = newDuration;
            _controller.forward();
            _controller.repeat(reverse: true);
          }

          if (status == AnimationStatus.forward) {
            audioPlayerService.play('assets/sounds/breath-in.ogg', widget.volume.toDouble(), 'in');
          } else if (status == AnimationStatus.reverse) {
            audioPlayerService.play('assets/sounds/breath-out.ogg', widget.volume.toDouble(), 'out');
          }
        } catch (error) {
          print('An error occurred: $error');
        }
      });
    }).catchError((error) {
      print('An error occurred: $error');
    });
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void didUpdateWidget(AnimatedCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
  
    if (widget.tempoDuration != oldWidget.tempoDuration) {
      _controller.duration = widget.tempoDuration;
      if (widget.controlCallback != null) {
        String control = widget.controlCallback!();
        if (control == 'reset') {
          _controller.reset();
          _stopAudio();
          _controller.forward();
          _controller.repeat(reverse: true);
        }
      }
    }
    if (widget.controlCallback != null) {
      String currentStatus = _controller.status.toString().split('.').last;
      String control = widget.controlCallback!();
      if (control != currentStatus) {
        switch (control) {
          case 'repeat':
            if (_controller.status == AnimationStatus.forward || _controller.status == AnimationStatus.reverse) break;
            _controller.forward();
            _controller.repeat(reverse: true);
            break;
          case 'forward':
            _controller.forward();
            break;
          case 'reverse':
            _controller.reverse();
            break;
          case 'stop':
            _stopAudio();
            _controller.stop();
            break;
          case 'reset':
            _stopAudio();
            _controller.stop();
            _controller.forward();
            _controller.repeat(reverse: true);
            break;
        }
      }
    }

  }
  void _stopAudio() async {
    await audioPlayerService.stop('in');
    await audioPlayerService.stop('out');
  }

  @override
  void dispose() async{
    _controller.dispose();

    audioPlayerService.disposePlayer('in');
    audioPlayerService.disposePlayer('out');
    super.dispose();
  }

 @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    return Center(
      child: CustomPaint(
        painter: BreathingCircle(_radiusAnimation, innerText: widget.innerText),
      ),
    );
  }
}

class BreathingCircle extends CustomPainter {
  final Animation<double> _animation;
  final String? innerText;

  BreathingCircle(this._animation, {this.innerText}) : super(repaint: _animation);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.teal;
    var paint2 = Paint();
    paint2.color = Colors.tealAccent;

    double radius = _animation.value;
    canvas.drawCircle(Offset(0.0, 100.0), 72, paint);
    canvas.drawCircle(Offset(0.0, 100.0), radius, paint2);
    
    String? displayText = innerText;

    int? numberValue = int.tryParse(innerText ?? '');

    if (numberValue != null && numberValue < 0) {
      displayText = numberValue.abs().toString();
    }

    if (displayText != null) {
      TextPainter textPainter = TextPainter(
        text: TextSpan(text: displayText, style: TextStyle(color: Colors.black, fontSize: 32.0)),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, 100.0 - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant BreathingCircle oldDelegate) {
    return oldDelegate.innerText != innerText;
  }
}
