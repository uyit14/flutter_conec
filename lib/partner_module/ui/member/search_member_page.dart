import 'dart:async';

import 'package:conecapp/common/api/api_response.dart';
import 'package:conecapp/common/ui/ui_error.dart';
import 'package:conecapp/common/ui/ui_loading.dart';
import 'package:conecapp/partner_module/models/search_m_response.dart';
import 'package:conecapp/partner_module/ui/member/member_bloc.dart';
import 'package:flutter/material.dart';

class SearchMemberPage extends StatefulWidget {
  static const ROUTE_NAME = '/search-member';

  @override
  _SearchMemberPageState createState() => _SearchMemberPageState();
}

class _SearchMemberPageState extends State<SearchMemberPage> {
  MemberBloc _memberBloc = MemberBloc();
  String _keyword = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text("Tìm kiếm")),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black12,
                    ),
                    height: 40,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                      maxLines: 1,
                      onChanged: (value) {
                        // Timer(const Duration(milliseconds: 1000), () {
                        //   _memberBloc.requestSearchMember(value);
                        // });
                        setState(() {
                          _keyword = value;
                        });
                      },
                      onFieldSubmitted: (value) {
                        _memberBloc.requestSearchMember(value);
                      },
                      textInputAction: TextInputAction.done,
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                          hintText: 'Tìm thành viên',
                          //prefixIcon: Icon(Icons.search),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: EdgeInsets.only(left: 8)),
                    ),
                  ),
                  InkWell(
                    child: Icon(Icons.search),
                    onTap: () {
                      _memberBloc.requestSearchMember(_keyword);
                    },
                  ),
                ],
              ),
              Container(
                color: Colors.black12,
                width: double.infinity,
                height: 1,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: StreamBuilder<ApiResponse<List<MemberSearch>>>(
                    stream: _memberBloc.memberSearchStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        switch (snapshot.data.status) {
                          case Status.LOADING:
                            return UILoading();
                          case Status.COMPLETED:
                            List<MemberSearch> memberSearch = snapshot.data.data;
                            return ListView.builder(
                                itemCount: memberSearch.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop(memberSearch[index]);
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width - 70,
                                                child: Text(
                                                  memberSearch[index].name ?? "",
                                                  style: TextStyle(fontSize: 16),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              CircleAvatar(
                                                radius: 18,
                                                backgroundColor: Colors.grey,
                                                backgroundImage: memberSearch[index].avatar != null
                                                    ? NetworkImage(memberSearch[index].avatar)
                                                    : AssetImage("assets/images/avatar.png"),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 12),
                                          Container(
                                            color: Colors.black12,
                                            width: double.infinity,
                                            height: .5,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          case Status.ERROR:
                            return UIError(errorMessage: snapshot.data.message);
                        }
                      }
                      return Container();
                    }),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
