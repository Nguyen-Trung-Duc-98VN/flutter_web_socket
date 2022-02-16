/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-19 09:37:56 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-19 09:38:16
 */
import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Transaction {
  Transaction();

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
