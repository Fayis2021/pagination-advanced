/// pagination_advanced
///
/// An advanced Flutter pagination package that handles infinite scroll,
/// pull-to-refresh, shimmer/skeleton loading, error/empty states, search,
/// filter, and cursor-based pagination — all out of the box.
///
/// ## Quick start
/// ```dart
/// import 'package:pagination_advanced/pagination_advanced.dart';
///
/// PaginatedListView<Product>(
///   fetch: (query) => api.getProducts(query),
///   loadingType: PaginationLoadingType.shimmer,
///   itemBuilder: (context, product) => ProductCard(product),
/// )
/// ```
library;

// Models
export 'src/models/pagination_query.dart';
export 'src/models/pagination_result.dart';
export 'src/models/pagination_state.dart';
export 'src/models/pagination_theme.dart';

// Controller
export 'src/controllers/pagination_controller.dart';

// BLoC (optional)
export 'src/bloc/pagination_event.dart';
export 'src/bloc/pagination_bloc.dart';

// Widgets – loaders
export 'src/widgets/loaders/pagination_shimmer.dart';

// Widgets – views
export 'src/widgets/paginated_builder.dart';
export 'src/widgets/paginated_list_view.dart';
export 'src/widgets/paginated_grid_view.dart';
export 'src/widgets/paginated_sliver_list.dart';
