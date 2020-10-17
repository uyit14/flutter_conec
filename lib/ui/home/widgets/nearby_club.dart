import 'package:conecapp/ui/home/blocs/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NearByClub extends StatefulWidget {
  @override
  _NearByClubState createState() => _NearByClubState();
}

class _NearByClubState extends State<NearByClub> {
  HomeBloc _homeBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeBloc = Provider.of<HomeBloc>(context);
    _homeBloc.requestGetTopic();
  }

  @override
  void dispose() {
    super.dispose();
    _homeBloc.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
