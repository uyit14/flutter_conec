import 'package:conecapp/dummy/dummy_data.dart';
import 'package:conecapp/ui/home/pages/items_by_category_page.dart';
import 'package:flutter/material.dart';

class AnimatedCategories extends StatefulWidget {
  @override
  _AnimatedCategoriesState createState() => _AnimatedCategoriesState();
}

class _AnimatedCategoriesState extends State<AnimatedCategories> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: AnimatedList(
        initialItemCount: DummyData.categories.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index, animation){
          return SlideTransition(
            position: CurvedAnimation(
              curve: Curves.easeOut,
              parent: animation,
            ).drive((Tween<Offset>(
              begin: Offset(1, 0),
              end: Offset(0, 0),
            ))),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(ItemByCategory.ROUTE_NAME,
                    arguments: {
                      'id': DummyData.categories[index].id,
                      'title': DummyData.categories[index].title
                    });
              },
              child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.2, color: Colors.grey),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: Offset(2, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  width: 100,
                  margin: EdgeInsets.all(4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        DummyData.categories[index].image,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                      Text(
                        DummyData.categories[index].title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500),
                      )
                    ],
                  )),
            ),
          );
        },
      )
    );
  }
}
