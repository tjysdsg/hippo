import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hippo/index.dart';

void main() {
  test('Get lessons from server', () async {
    var res = await getPracticeData();
    const expected =
        '[Lesson 1, Greetings, [Dialog 1, [Sentence 1, 你, Sentence 2, 好, Sentence 3, 请, Sentence 4, 问, Sentence 5, 贵, Sentence 6, 姓, Sentence 7, 我, Sentence 8, 呢, Sentence 9, 小姐, Sentence 10, 叫, Sentence 11, 什么, Sentence 12, 名字, Sentence 13, 先生, Sentence 14, 李友, Sentence 15, 李, Sentence 16, 王朋, Sentence 17, 王], Dialog 2, [Sentence 18, 是, Sentence 19, 老师, Sentence 20, 吗, Sentence 21, 不, Sentence 22, 学生, Sentence 23, 也, Sentence 24, 人, Sentence 25, 中国, Sentence 26, 北京, Sentence 27, 美国, Sentence 28, 纽约]], Lesson 2, Family, [Dialog 3, [Sentence 29, 那, Sentence 30, 的, Sentence 31, 照片, Sentence 32, 这, Sentence 33, 爸爸, Sentence 34, 妈妈, Sentence 35, 个, Sentence 36, 女, Sentence 37, 孩子, Sentence 38, 谁, Sentence 39, 她, Sentence 40, 姐姐, Sentence 41, 男, Sentence 42, 弟弟, Sentence 43, 他, Sentence 44, 大哥, Sentence 45, 儿子, Sentence 46, 有, Sentence 47, 女儿, Sentence 48, 没, Sentence 49, 高文中, Sentence 50, 高], Dialog 4, [Sentence 51, 家, Sentence 52, 几, Sentence 53, 口, Sentence 54, 哥哥, Sentence 55, 两, Sentence 56, 妹妹, Sentence 57, 和, Sentence 58, 大姐, Sentence 59, 二姐, Sentence 60, 做, Sentence 61, 工作, Sentence 62, 律师, Sentence 63, 英文, Sentence 64, 都, Sentence 65, 大学生, Sentence 66, 大学, Sentence 67, 医生, Sentence 68, 白英爱]]]';
    var actual = utf8.decode(res.toString().runes.toList());
    expect(actual, expected);
  });
}
