import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget loading() {
  return Center(
    child: PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AppBar(
            backgroundColor: Colors.transparent,
            leading: const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/person.jpg'),
            ),
            title: Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: Colors.grey,
                child: Container(
                  width: 10,
                  height: 10,
                  color: Colors.white,
                ))),
      ),
    ),
  );
}
