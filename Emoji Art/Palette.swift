//
//  Palette.swift
//  Emoji Art
//
//  Created by N L on 4. 8. 2025..
//

import Foundation
// Model_Two
struct Palette: Identifiable {
    var name: String
    var emojis: String
    let id = UUID() // UUID hashable
    
    static let builtins = [
        Palette(name: "Vehicles", emojis: "🚗🚕🚙🚌🚎🏎🚓🚑🚒🚐🛻🚚🚛🚜✈️🛩🛫🛬🚁🚟🚠🚡🛶⛵️🚤🛥🛳⛴🚢🚂🚆🚇🚈🚝🚄🚅🚈🚞🚋🚃🚎🛴🚲🛵🏍🛺"),
        Palette(name: "Sports", emojis: "⚽️🏀🏈⚾️🥎🎾🏐🏉🥏🎱🏓🏸🥅⛳️🥌⛷🏂🪂🏋️‍♀️🤼‍♂️🤸‍♀️⛹️‍♀️🤺🤾‍♂️🏌️‍♀️🏇🧘‍♀️🏄‍♂️🏊‍♀️🤽‍♂️🚣‍♀️🧗‍♀️🚵‍♀️🚴‍♀️"),
        Palette(name: "Music", emojis: "🎼🎹🎻🥁🎷🎺🪗🎸"),
        Palette(name: "Animals", emojis: "🐥🦆🐄🐖🐐🐑🐎🦒🦘🐓🐁🐇🦃🕊🦉🦅🦆🦇🐍🦎🦖🦕🐊🦏🦣🦍🦧🐘🦛🐪🐫🦬🐃🐂🐄🦌🦙🐐🐏🐑🐕🐩🦮🦜🦢🦩🕊🦝"),
        Palette(name: "Animal Faces", emojis: "🐵🙈🙉🙊🐶🐱🐭🐹🐰🦊🦝🐻🐼🦘🦡🐨🐯🦁🐮🐷🐸🐵"),
        Palette(name: "Flora", emojis: "🌲🌴🌿☘️🍀🎍🎋🍃🍂🍁🍄🌾🌺🌻🌹🥀🌷🌼🌸💐"),
        Palette(name: "Weather", emojis: "☀️🌤⛅️🌥☁️🌦🌧⛈🌩🌨❄️☃️⛄️🌬💨💧💦🌊🌪"),
        Palette(name: "COVID", emojis: "💉🦠😷🤒🤧"),
        Palette(name: "Faces", emojis: "😀😃😄😁😆😅😂🤣😊😇🙂🙃😉😌😍😘😗😙😚😋😛😝😜🤪🤨🧐🤓😎🥸🤩🥳😏😒😞😔😟😕🙁☹️😣😖😫😩🥺😢😭😤😠😡🤯😲😨😰🥶🥵😳🥴😵‍💫😵🤢🤮🤧😷🤒🤕🤑🤠")
    ]

}
