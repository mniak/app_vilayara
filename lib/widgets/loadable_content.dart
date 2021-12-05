import 'package:app_comunicacao_vilayara/widgets/loading.dart';
import 'package:flutter/widgets.dart';

class LoadableContent extends StatelessWidget {
  final LoadedFunction loaded;
  final Widget child;
  final Widget loading;

  LoadableContent({
    @required this.child,
    LoadedFunction loaded,
    Widget loading,
  })  : this.loaded = loaded != null ? loaded : (() => true),
        this.loading = loading ?? Loading();

  @override
  Widget build(BuildContext context) => loaded() ? child : loading;
}

typedef bool LoadedFunction();
