import Foundation
import Testing

@testable import SPFKTime

struct MusicalPulseDescriptionTests {
    @Test func timeToTestValue() {
        #expect(MusicalPulseDescription(time: 0.04).stringValue == "1 1 1")
        #expect(MusicalPulseDescription(time: 0.21275498516968402).stringValue == "1 1 2")
        #expect(MusicalPulseDescription(time: 0.3370278526551341).stringValue == "1 1 3")
        #expect(MusicalPulseDescription(time: 0.47059639673108494).stringValue == "1 1 4")
        #expect(MusicalPulseDescription(time: 0.47059639673108494).stringValue == "1 1 4")
        #expect(MusicalPulseDescription(time: 0.6139770438747866).stringValue == "1 2 1")
        #expect(MusicalPulseDescription(time: 0.6131507615111865).stringValue == "1 2 1")
        #expect(MusicalPulseDescription(time: 0.6129235338611966).stringValue == "1 2 1")
        #expect(MusicalPulseDescription(time: 0.7469671902962174).stringValue == "1 2 2")
        #expect(MusicalPulseDescription(time: 0.8386225614785549).stringValue == "1 2 3")
        #expect(MusicalPulseDescription(time: 0.963948938977595).stringValue == "1 2 4")
        #expect(MusicalPulseDescription(time: 0.963948938977595).stringValue == "1 2 4")
        #expect(MusicalPulseDescription(time: 0.963948938977595).stringValue == "1 2 4")
        #expect(MusicalPulseDescription(time: 0.963577111913975).stringValue == "1 2 4")
        #expect(MusicalPulseDescription(time: 1.0718820727228537).stringValue == "1 3 1")
        #expect(MusicalPulseDescription(time: 1.1909700183767136).stringValue == "1 3 2")
        #expect(MusicalPulseDescription(time: 1.3245592195117544).stringValue == "1 3 3")
        #expect(MusicalPulseDescription(time: 1.4625277171738755).stringValue == "1 3 4")
        #expect(MusicalPulseDescription(time: 1.5703988797418642).stringValue == "1 4 1")
        #expect(MusicalPulseDescription(time: 1.5703782226827743).stringValue == "1 4 1")
        #expect(MusicalPulseDescription(time: 1.5698411391464342).stringValue == "1 4 1")
        #expect(MusicalPulseDescription(time: 1.7079129221040055).stringValue == "1 4 2")
        #expect(MusicalPulseDescription(time: 1.7082640921085355).stringValue == "1 4 2")
        #expect(MusicalPulseDescription(time: 1.7115072503856656).stringValue == "1 4 2")
        #expect(MusicalPulseDescription(time: 1.8450551374025266).stringValue == "1 4 3")
        #expect(MusicalPulseDescription(time: 1.8452203938752465).stringValue == "1 4 3")
        #expect(MusicalPulseDescription(time: 1.8454063074070566).stringValue == "1 4 3")
        #expect(MusicalPulseDescription(time: 1.9580699076839256).stringValue == "1 4 4")
        #expect(MusicalPulseDescription(time: 1.9580699076839256).stringValue == "1 4 4")
        #expect(MusicalPulseDescription(time: 1.959660501233856).stringValue == "1 4 4")
        #expect(MusicalPulseDescription(time: 2.085565276387416).stringValue == "2 1 1")
        #expect(MusicalPulseDescription(time: 2.086102359923756).stringValue == "2 1 1")
        #expect(MusicalPulseDescription(time: 2.086102359923756).stringValue == "2 1 1")
    }
}
