import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:personal_budget/bloc/blocs.dart';
import 'package:personal_budget/models/record.dart';
import 'package:personal_budget/data/record_repository.dart';

class RecordBloc extends Bloc<RecordEvent, RecordState> {

  final RecordRepository recordRepository;

  RecordBloc({@required this.recordRepository});

  @override
  RecordState get initialState => RecordEmpty();

  @override
  Stream<RecordState> mapEventToState(RecordState currentState, RecordEvent event
  ) async* {
    if(event is FetchRecord){
      yield RecordLoading();
      try {
        final List<Record> records = await recordRepository.getRecords();
        print(records);
        yield RecordLoaded(records: records);
      } catch (e) {
        print(e.toString());
        yield RecordError();
      }
    }
    if(event is AddRecord){
      yield RecordLoading();
      try {
        final record = recordRepository.addRecord(event.record);
        yield RecordSaved(record: record);
      } catch (e) {
        yield RecordError();
      }
    }
    if(event is UpdateRecord){
      yield RecordLoading();
      try {
        final record = recordRepository.updateRecord(event.record);
        yield RecordSaved(record: record);
      } catch (e) {
        yield RecordError();
      }
    }
    if(event is DeleteRecord){
      yield RecordLoading();
      try {
        final record = recordRepository.deleteRecord(event.record);
        yield RecordDeleted(record: record);
      } catch (e) {
        yield RecordError();
      }
    }
  }

}