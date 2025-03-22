import 'package:flutter/material.dart';

import '../../../../res/constants.dart';

class AnimatedLinearProgressIndicator extends StatelessWidget {
  const AnimatedLinearProgressIndicator({super.key, required this.percentage, required this.title, this.image});
  final double percentage;
  final String title;
  final String? image;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  const EdgeInsets.only(bottom: defaultPadding/2),
      child: TweenAnimationBuilder(tween: Tween(begin: 0.0,end: percentage), duration: const Duration(seconds: 1), builder: (context, value, child) {
        return Column(
          children: [
            Row(
              children: [
                Image.asset(image!,height: 15,width: 15,fit: BoxFit.cover,),
                const SizedBox(width: 5,),
                Text(title,style: const TextStyle(color: Colors.white),),
                const Spacer(),
                Text('${(value*100).toInt().toString()}%'),
              ],
            ),
            const SizedBox(height: defaultPadding/2,),
            LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.black,
              color: Colors.amberAccent,
            ),
          ],
        );
      },),
    );
  }
}

class MySKills extends StatelessWidget {
  const MySKills({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedLinearProgressIndicator(percentage: 0.9, title: 'Flutter',image: 'assets/icons/flutter.png',),
        AnimatedLinearProgressIndicator(percentage: 0.9, title: 'Dart',image: 'assets/icons/dart.png'),
        AnimatedLinearProgressIndicator(percentage: 0.85, title: 'Firebase',image: 'assets/icons/firebase.png'),
        AnimatedLinearProgressIndicator(percentage: 0.70, title: 'Sqlite',image: 'assets/icons/dart.png'),
        AnimatedLinearProgressIndicator(percentage: 0.8, title: 'Responsive Design',image: 'assets/icons/flutter.png'),
        AnimatedLinearProgressIndicator(percentage: 0.9, title: 'Clean Architecture',image: 'assets/icons/flutter.png'),
        AnimatedLinearProgressIndicator(percentage: 0.7, title: 'Bloc',image: 'assets/icons/bloc.png'),
        AnimatedLinearProgressIndicator(percentage: 0.9, title: 'Getx',image: 'assets/icons/dart.png'),
        AnimatedLinearProgressIndicator(percentage: 0.85, title: 'Java',image: 'assets/icons/java.png'),
        AnimatedLinearProgressIndicator(percentage: 0.80, title: 'Kotlin',image: 'assets/icons/kotlin.png'),
        AnimatedLinearProgressIndicator(percentage: 0.73, title: 'C',image: 'assets/icons/c.png'),
        AnimatedLinearProgressIndicator(percentage: 0.70, title: 'Go',image: 'assets/icons/go.png'),
        AnimatedLinearProgressIndicator(percentage: 0.70, title: 'PostgreSQL',image: 'assets/icons/postgresql.png'),
      ],);
  }
}
