// ignore_for_file: unused_import, must_be_immutable, unused_element

import 'dart:js';

import 'package:client/textComponent.dart';
import 'package:flutter/material.dart';
import 'resources.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';

class DashBoardGridTile extends StatelessWidget {
  late String head, link;
  late String icon;
  DashBoardGridTile({
    Key? key,
    required String head,
    required String link,
    required String icon,
  }) : super(key: key) {
    this.head = head;
    this.link = link;
    this.icon = icon;
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          // width: 100,
          // height: 100,
          padding: EdgeInsets.only(left: 50, right: 50, top: 30, bottom: 30),
          // color: MyColors.cobaltBlue,
          // padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border.all(color: MyColors.cobaltBlue, width: 5),
              borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/imageAssets/$icon',
                  width: 100,
                  height: 100,
                ),
                Text(
                  head,
                  style: txtbstyle,
                )
              ],
            ),
          )),
      onTap: () => null,
      // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> DriverForm()))
    );
  }
}

// class SideBar extends StatelessWidget{
//   double width;
//   List <Widget> children;
//   Color? color;
//   SideBar({Key? key,required this.children,this.width=250,this.color=Colors.white70}):super(key: key);

//   Widget build(BuildContext context){
//     return Container(
//             decoration: BoxDecoration(
//               color: Color(0xff057DCD),
//               border: Border.all(color: Colors.black12,width: 2),
//               borderRadius: BorderRadius.circular(5)
//             ),
//             // color: Colors.grey,
//             width: this.width,
//             // height: 400,
//             padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
//             child: Column(
//               mainAxisSize: MainAxisSize.max,
//               children: this.children,
//             ),
//           );
//   }
// }

class SideBar extends StatelessWidget {
  SideBar(
      {Key? key,
      required this.context,
      required this.controller,
      required this.width,
      required this.displayMode})
      : super(key: key);
  PageController controller;
  BuildContext context;
  double width;
  SideMenuDisplayMode displayMode;
  Function _onTap(String routeName) => () {
        Navigator.pushNamed(this.context, routeName);
      };

  // @override
  // void initState(){
  //   super.initState();
  //   page.addListener(() {
  //     if(MediaQuery.of(context))
  //   })
  // }

  List<SideMenuItem> items() {
    List<SideMenuItem> items = [
      SideMenuItem(
        priority: 0,
        title: "Dashboard",
        onTap: () {
          // Navigator.pushNamed(context, "/dashboard");
          controller.jumpToPage(0);
        },
        // routeName: "/dashboard",
        icon: Icons.home,
      ),
      SideMenuItem(
          priority: 1,
          title: "Drivers",
          onTap: () {
            // Navigator.pushNamed(context, "/driverAddForm");
            controller.jumpToPage(1);
            // controller.attach(position)
          },
          // onTap: (){Navigator.pushNamed(context, routeName)},
          icon: Icons.person),
      SideMenuItem(
        priority: 2,
        title: "Buses",
        onTap: () {
          // Navigator.pushNamed(context, "/driverAddForm");
          controller.jumpToPage(2);
        },
        // onTap: (){controller.jumpTo(value)},
        icon: Icons.directions_bus_rounded,
      ),
      SideMenuItem(
        priority: 3,
        title: "Bus Stops",
        onTap: () {
          // Navigator.pushNamed(context, "/driverAddForm");
          controller.jumpToPage(3);
        },
        icon: Icons.bus_alert,
      ),
      SideMenuItem(
          priority: 4,
          title: "Routes",
          onTap: () {
            // Navigator.pushNamed(context, "/driverAddForm");
            controller.jumpToPage(4);
          },
          // onTap: (){controller.jumpTo(value)},
          icon: Icons.map_rounded),
    ];
    return items;
  }

  @override
  Widget build(BuildContext context) {
    // controller.addListener();
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (MediaQuery.of(context).size.width > 1300) {
        return SideMenu(
          title: Image.asset(
            'assets/imageAssets/logo.png',
            width: 300,
            height: 150,
          ),
          items: items(),
          controller: this.controller,
          style: SideMenuStyle(
              selectedTitleTextStyle: TextStyle(color: Colors.white),
              unselectedTitleTextStyle: TextStyle(color: Colors.grey.shade800),
              unselectedIconColor: Colors.grey.shade800,
              selectedIconColor: Colors.white,
              hoverColor: Colors.white,
              selectedColor: MyColors.cobaltBlue,
              backgroundColor: Colors.grey.shade300,
              displayMode: SideMenuDisplayMode.open),
        );
      } else {
        return SideMenu(
          title: Image.asset('assets/imageAssets/logo.png'),
          items: items(),
          controller: this.controller,
          style: SideMenuStyle(
              unselectedIconColor: Colors.grey.shade800,
              selectedIconColor: Colors.white,
              hoverColor: Colors.white,
              selectedColor: MyColors.cobaltBlue,
              displayMode: SideMenuDisplayMode.compact),
        );
      }
    });
  }
}

class ColoredContainer extends StatelessWidget {
  ColoredContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      color: Colors.black,
    );
  }
}
