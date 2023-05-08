import 'dart:math';

import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../library/data/project.dart';
import '../library/functions.dart';

class ProjectListView extends StatelessWidget {
  final List<Project> projects;
  final Function(Project) onProjectTapped;
  const ProjectListView({
    super.key,
    required this.projects,
    required this.onProjectTapped,
  });

  @override
  Widget build(BuildContext context) {
    final Random random = Random(DateTime.now().millisecondsSinceEpoch);
    final images = getImages();

    return ScreenTypeLayout(mobile: SizedBox(
        height: 220,
        child: ListView.builder(
          itemCount: projects.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final project = projects.elementAt(index);
            Image image;
            if (index < images.length) {
              image = images.elementAt(index);
            } else {
              final m = random.nextInt(images.length - 1);
              image = images.elementAt(m);
            }
            return GestureDetector(
              onTap: (){
                pp('........ project tapped: ${project.name}');
                onProjectTapped(project);
              },
              child: ProjectView(
                  image: image, project: project, height: 212, width: 242),
            );
          },
        )),
    tablet: OrientationLayoutBuilder(portrait: (context){
      return SizedBox(
          height: 320,
          child: ListView.builder(
            itemCount: projects.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final project = projects.elementAt(index);
              Image image;
              if (index < images.length) {
                image = images.elementAt(index);
              } else {
                final m = random.nextInt(images.length - 1);
                image = images.elementAt(m);
              }
              return GestureDetector(
                onTap: (){
                  pp('........ project tapped: ${project.name}');
                  onProjectTapped(project);
                },
                child: ProjectView(
                    image: image, project: project, height: 312, width: 312),
              );
            },
          ));

    },
      landscape: (context){
       return SizedBox(
           height: 220,
           child: ListView.builder(
             itemCount: projects.length,
             scrollDirection: Axis.horizontal,
             itemBuilder: (context, index) {
               final project = projects.elementAt(index);
               Image image;
               if (index < images.length) {
                 image = images.elementAt(index);
               } else {
                 final m = random.nextInt(images.length - 1);
                 image = images.elementAt(m);
               }
               return GestureDetector(
                 onTap: (){
                   pp('........ project tapped: ${project.name}');
                   onProjectTapped(project);
                 },
                 child: ProjectView(
                     image: image, project: project, height: 212, width: 242),
               );
             },
           ));
      },
    ),
    );
  }
}

class ProjectView extends StatelessWidget {
  const ProjectView(
      {Key? key,
      required this.project,
      required this.height,
      required this.width,
      required this.image,})
      : super(key: key);
  final Project project;
  final double height, width;
  final Image image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Card(
        shape: getRoundedBorder(radius: 10),
        elevation: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Flexible(
                    child: Text(
                      '${project.name}',
                      overflow: TextOverflow.ellipsis,
                      style: myTextStyleSmallBlackBold(context),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            ClipRRect(borderRadius: BorderRadius.circular(10.0), child: image)
          ],
        ),
      ),
    );
  }
}
