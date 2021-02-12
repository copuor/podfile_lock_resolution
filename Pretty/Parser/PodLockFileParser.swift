//
//  PodLockFileParser.swift
//  解析 Podfile.lock 的 PODS: 字段，获取 pod 间的依赖关系
//
//  Created by Octree on 2018/4/5.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation

/// 三种基础的文本处理方案
///
/// 
/// Just parse one character
///
/// - Parameter condition: condition
/// - Returns: Parser<Character>
func character(matching condition: @escaping (Character) -> Bool) -> Parser<Character> {
    
    return Parser(parseX: { input in
        guard let char = input.first, condition(char) else {
            return nil
        }
        return (char, input.dropFirst())
    })
}


/// parse one specific character
///
/// - Parameter ch: character
/// - Returns: Parser<Character>
func character(_ ch: Character) -> Parser<Character> {
    
    return character {
        $0 == ch
    }
}


/// Parse Specific String
///
/// - Parameter string: expected string
/// - Returns: Parser<String>
func string(_ string: String) -> Parser<String> {
    
    return Parser { input in
        
        guard input.hasPrefix(string) else {
            return nil
        }
        return (string, input.dropFirst(string.count))
    }
}

/// 冒号
private let colon = character { $0 == ":" }

/// 空格
private let space = character(" ")

/// 换行
private let newLine = character("\n")

/// 缩进
private let indentation = space.followed(by: space)

/// -
private let hyphon = character("-")
private let quote = character("\"")

private let leftParent = character("(")
private let rightParent: Parser<Character> = character(")")

/// Just Parse `PODS:` 😅
private let podsX: Parser<String> = string("PODS:\n")

private let word: Parser<String> = character {
    !CharacterSet.whitespacesAndNewlines.contains($0) }.many.convert{ String($0) }


// 这个有意思， 这里直观
/// Parse Version Part: `(= 1.2.2)` or `(1.2.3)` or `(whatever)`
private let version: Parser<((Character, [Character]), Character)> = leftParent.followed(by: character { $0 != ")" }.many).followed(by: rightParent)

// 调用的简洁，意味着维护了多余的结构
// 链式编程，操作符返回 self
private let item: Parser<String> = (indentation *> hyphon *> space *> quote.optional *> word)
    <* (space.followed(by: version)).optional <* quote.optional <* colon.optional <* newLine

private let subItem: Parser<String> = indentation *> item
// 很有意思的, 链式调用

// 定义数据处理的逻辑单元， 函数式编程
private let dependencyItem: Parser<(String, [String])> = Parser<([String]?) -> (String, [String])> {
    input in
    guard let (result, remainder) = item.parseX(input) else {
        return nil
    }
    return ({ y in (result, y ?? []) }, remainder)
}.followed(by: subItem.many.optional).convert{ $0($1) }



private let dependencyItems: Parser<[String: [String]]> = dependencyItem.many.convert{ x -> [String : [String]] in
    var map = [String: [String]]()
    x.forEach { map[$0.0] = $0.1 }
    return map
}

typealias ResultFmt = [String: [String]]

/// 解析 Podfile.lock
/// 解析成功会返回 [String: [String]]
/// key: Pod Name
/// value: 该 Pod 依赖的其他 Pods
let PodLockFileParser: Parser<ResultFmt> = {
    let qu = Parser<(ResultFmt) -> ResultFmt>{
        input in
        guard let (_, remainder) = podsX.parseX(input) else {
            return nil
        }
        return ({a in a}, remainder)
    }
    let hao: Parser<((ResultFmt) -> ResultFmt, ResultFmt)> = qu.followed(by: dependencyItems)
    
    return Parser<ResultFmt>{
        input in
        guard let (result, remainder) = hao.parseX(input) else {
            return nil
        }
        return (result.1, remainder)
    }
}()


