import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:personal_budget/category/category_detail.dart';
import 'package:personal_budget/models/category.dart';
import 'package:personal_budget/models/category_data.dart';
import 'package:provider/provider.dart';

///CategoryList
class CategoryList extends StatelessWidget {
  void _navigateToCategoryDetail(
      BuildContext context, Category category) async {
    final categoryResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetail(category: category),
      ),
    );

    if (categoryResult != null) {
      if (categoryResult.id != null) {
        Provider.of<CategoryData>(context)
            .updateCategory(categoryResult);
      } else {
        Provider.of<CategoryData>(context).addCategory(categoryResult);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // _categoryBloc = App.of(context).categoryBloc;
    // _categoryBloc.dispatch(FetchCategory());
    return Scaffold(
      appBar: AppBar(
        title: Text('Categorias'),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
              flex: 1,
              child: Container(
                color: Color(0xfff3f3f3),
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Clique sobre a categoria para poder editar ou deletar a mesma.',
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w200),
                ),
              )),
          Flexible(
              flex: 3,
              child: Consumer<CategoryData>(
                  builder: (context, categoryData, child) {
                return FutureBuilder<UnmodifiableListView<Category>>(
                  future: categoryData.categories,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return provideListItem(
                                context, snapshot.data[index]);
                          });
                    }
                    return CircularProgressIndicator();
                  },
                );
              }))
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _navigateToCategoryDetail(context, Category());
          }),
    );
  }

  Widget provideListItem(BuildContext context, Category category) {
    return Dismissible(
      onDismissed: (direction) {
        Provider.of<CategoryData>(context).deleteCategory(category);

        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text("${category.title} removida com sucesso.")));
      },
      key: Key(category.title),
      child: ListTile(
        title: Text(
          category.title.toUpperCase(),
          style: TextStyle(
              color: Color(category.color),
              fontSize: 12,
              fontWeight: FontWeight.bold),
        ),
        onTap: () {
          _navigateToCategoryDetail(context, category);
        },
      ),
    );
  }
}
