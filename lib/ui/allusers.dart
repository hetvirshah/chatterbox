import 'package:chatterjii/features/auth/userscubit.dart';
import 'package:chatterjii/app/routes.dart';
import 'package:chatterjii/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      fetchUsers();
    });
  }

  void fetchUsers() {
    context.read<UserCubit>().fetchUsers();
  }

  void searchUsers(String query) {
    context.read<UserCubit>().searchUsers(query);
  }

  Widget noData() {
    return const Center(
      child: Text(
        'No Users found.',
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.indigo.withOpacity(0.3),
              hintText: 'Search by username',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none),
            ),
            onChanged: (query) {
              searchUsers(query);
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<UserCubit, UsersState>(
            builder: (context, state) {
              if (state is UsersLoading) {
                return loading();
              } else if (state is UsersLoaded) {
                if (state.users.isEmpty) {
                  return noData();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ListView.builder(
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      return ListTile(
                          leading: const CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage('assets/person.jpg'),
                          ),
                          title: Text(user.displayName,
                              style: const TextStyle(fontSize: 16)),
                          subtitle: Text(user.email,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black.withOpacity(0.5))),
                          onTap: () => Navigator.pushNamed(
                                context,
                                Routes.chats,
                                arguments: {
                                  'peerId': user.uid,
                                  'peerName': user.displayName,
                                },
                              ));
                    },
                  ),
                );
              } else if (state is UsersError) {
                return Center(child: Text(state.message));
              }
              return Container();
            },
          ),
        ),
      ],
    );
  }
}
