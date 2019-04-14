import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_budget/bloc/blocs.dart';
import 'package:personal_budget/main.dart';
import 'package:personal_budget/models/category.dart';
import 'package:personal_budget/models/record.dart';
import 'package:personal_budget/models/record_data.dart';
import 'package:personal_budget/widget/amount_widget.dart';
import 'package:personal_budget/widget/category_widget.dart';
import 'package:personal_budget/widget/date_picker_widget.dart';
import 'package:personal_budget/widget/description_widget.dart';

class RecordDetail extends StatefulWidget {
  final Record record;
  RecordDetail({Key key, this.record}) : super(key: key);

  @override
  _RecordDetailState createState() => _RecordDetailState();
}

class _RecordDetailState extends State<RecordDetail> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyAmount = GlobalKey<FormState>();
  RecordData _data = RecordData();
  bool isExpense;
  CategoryBloc _categoryBloc;

  void _submit(bool isExpense) {
    if (_formKey.currentState.validate() &&
        _formKeyAmount.currentState.validate()) {
      _formKey.currentState.save();
      _formKeyAmount.currentState.save();
      Navigator.pop(context, _data.toPersistentModel(isExpense));
    }
  }

  @override
  void initState() {
    super.initState();

    if(widget.record != null){
      isExpense = widget.record.isExpense;
    } else {
      isExpense = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Record record = widget.record;
    _categoryBloc = App.of(context).categoryBloc;
    _categoryBloc.dispatch(FetchCategory());

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Switch(
            value: isExpense,
            onChanged: (value) {
              setState(() {
                isExpense = value;
              });
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
            inactiveTrackColor: Colors.red.shade300,
          ),
        ],
        backgroundColor:
            isExpense ? Colors.redAccent : Colors.lightGreen.shade500,
        bottom: PreferredSize(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(80.0, 0.0, 16.0, 36.0),
            child: Form(
              key: _formKeyAmount,
              child: AmountWidget(
                  record: record, isSwitched: isExpense, data: _data),
            ),
          ),
          preferredSize: Size(0.0, 100.0),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  DescriptionWidget(record: record, data: _data, isExpense: isExpense),
                  BlocBuilder(
                      bloc: _categoryBloc,
                      builder: (_, CategoryState state) {
                        if(state is CategoryLoaded){
                          return CategoryWidget(record: record, data: _data, categories: state.categories);
                        }
                        if(state is CategoryLoading){
                          return CircularProgressIndicator();
                        }
                        if(state is CategoryEmpty || state is CategoryError){
                          return CategoryWidget(record: record, data: _data, categories: [Category(title: 'UNCATEGORIZED', color: Colors.red.value)]);
                        }
                      }),
                  DatePickerWidget(record: record, data: _data, isExpense: isExpense,),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _submit(isExpense);
        },
        tooltip: 'Increment',
        child: Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  @override
  void dispose() {
    _categoryBloc.dispose();
    super.dispose();
  }
}
