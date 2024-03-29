//
//  File.swift
//  
//
//  Created by Manuel S. Gomez on 8/13/20.
//

import Foundation

class TestResources {

    static let samplePoint = """
{
  "type": "Point",
  "coordinates": [-73.97604935657381, 40.631275905646774]
}
"""

    static let sampleLineString = """
{
  "type": "LineString",
  "coordinates": [
    [-73.97604935657381, 40.631275905646774],
    [-74.00236943480249, 40.63895767781394]
  ]
}
"""

    static let samplePolygon = """
{
  "type": "Polygon",
  "coordinates": [
    [
      [-73.97604935657381, 40.631275905646774],
      [-73.97716511994669, 40.63074665412933],
      [-73.97699848928193, 40.629871496125375],
      [-73.9768496430902, 40.6290885814784],
      [-73.97669604371914, 40.628354564208756],
      [-73.97657775689153, 40.62757318681896],
      [-73.9765146210018, 40.627294490493874],
      [-73.97644970441577, 40.627008255472994],
      [-73.97623453682755, 40.625976350730234],
      [-73.97726150032737, 40.6258527728136],
      [-73.97719665645002, 40.62510197855896],
      [-73.97710959292857, 40.62494825969152],
      [-73.97694382374165, 40.624052750014684],
      [-73.9768346520651, 40.62348104194568],
      [-73.97675209645574, 40.623013312325725],
      [-73.97656583927008, 40.6219949031937],
      [-73.97695070814679, 40.62163000717454],
      [-73.97705352864567, 40.6215325218076],
      [-73.97539380523678, 40.62076998723733],
      [-73.97682433557303, 40.61867580015917],
      [-73.97752301889588, 40.61767654076734],
      [-73.97785009338085, 40.6172876067946],
      [-73.97562954146068, 40.61594539066695],
      [-73.97537335532121, 40.6157547223824],
      [-73.97544276701358, 40.61611409035504],
      [-73.97548096980243, 40.616311925144196],
      [-73.97444328442452, 40.6164216434621],
      [-73.97335879350746, 40.6165417152966],
      [-73.97290326943272, 40.61415296838451],
      [-73.97399319461375, 40.61402989424251],
      [-73.97517176991693, 40.614724185881045],
      [-73.97497264664409, 40.6136681101718],
      [-73.97489295756654, 40.61318636841404],
      [-73.97477657974535, 40.61263847492685],
      [-73.97520829413772, 40.6128852582153],
      [-73.9774081645899, 40.61421811299029],
      [-73.97963821772845, 40.61556454722805],
      [-73.98003930358351, 40.61580692966757],
      [-73.9808791278371, 40.616314434788244],
      [-73.98186818243128, 40.616912126603815],
      [-73.9840679176659, 40.618240739302685],
      [-73.98627524709667, 40.619566616589694],
      [-73.98569357824182, 40.620131514447586],
      [-73.9878509553418, 40.62143503244062],
      [-73.99009356051286, 40.62278895334304],
      [-73.99254973616581, 40.62427426877921],
      [-73.99398197149371, 40.62514139905055],
      [-73.99432497413301, 40.62534290879742],
      [-73.99489280561376, 40.6254617941917],
      [-73.99473485679263, 40.62561474060342],
      [-73.99464972974172, 40.62569717922155],
      [-73.99507814869848, 40.6258067378371],
      [-73.99678847531307, 40.62682605141273],
      [-73.99687778353756, 40.626530782562355],
      [-73.99701633648009, 40.626061615450624],
      [-73.9972406703973, 40.62528868702803],
      [-73.99811614328407, 40.62581570660958],
      [-74.00031369476771, 40.62714458259374],
      [-74.00251454806298, 40.62847420956256],
      [-74.00222793396246, 40.62875116964375],
      [-74.00193011441125, 40.62903276789135],
      [-74.00306154030783, 40.629715175404556],
      [-74.00368597245085, 40.6300917810278],
      [-74.00413727968571, 40.63036396583654],
      [-74.00633870652992, 40.63169362668358],
      [-74.00702302486354, 40.63210999547638],
      [-74.00680677851517, 40.632250391235324],
      [-74.00661914959808, 40.63237545858945],
      [-74.00630615538647, 40.63258408846229],
      [-74.00556490392157, 40.6330831764142],
      [-74.00735636662998, 40.63416362723899],
      [-74.00675122718053, 40.63474478652965],
      [-74.00641784683815, 40.63506485045547],
      [-74.00616926871128, 40.635303501916034],
      [-74.00558613003881, 40.63586622903328],
      [-74.00500346527615, 40.63642523517754],
      [-74.00442048380327, 40.6369849863617],
      [-74.00411104085093, 40.63728296100241],
      [-74.00383793090822, 40.637545931867386],
      [-74.00325273129657, 40.638104262022885],
      [-74.00267214342664, 40.63866701046998],
      [-74.00236943480249, 40.63895767781394],
      [-74.0020907543513, 40.6392252543082],
      [-74.00150771254626, 40.6397849620733],
      [-74.00092541773434, 40.64034590202875],
      [-74.00066078180645, 40.64059930920131],
      [-74.00034122066634, 40.64090531617318],
      [-73.99975690844894, 40.64146715044591],
      [-73.9991756471891, 40.642025442029095],
      [-73.99697357409411, 40.64069410459458],
      [-73.99551033762245, 40.63980966713005],
      [-73.99479539539372, 40.640288487384396],
      [-73.99433124126968, 40.6406002879529],
      [-73.99407692009133, 40.64077040176035],
      [-73.99336253671026, 40.64124779897801],
      [-73.9926445605762, 40.641728290946446],
      [-73.99192812375553, 40.6422049040861],
      [-73.99121277380051, 40.64268589050532],
      [-73.99049634082614, 40.64316444118841],
      [-73.98977890274075, 40.643644886730954],
      [-73.98905872393608, 40.64411924103919],
      [-73.98834986671028, 40.64456224388724],
      [-73.98749940592022, 40.64404551035482],
      [-73.98673080569073, 40.64357399370719],
      [-73.985896444915, 40.64306759533013],
      [-73.98509519639006, 40.64257305584113],
      [-73.984587194825, 40.6422620045726],
      [-73.98430293143333, 40.64208456309331],
      [-73.98331628452111, 40.6414786828331],
      [-73.98299419241442, 40.6413249968491],
      [-73.98244454219795, 40.64153862556193],
      [-73.98204321765255, 40.6417075820055],
      [-73.98123240501364, 40.6420449138903],
      [-73.98042057821881, 40.64238522690571],
      [-73.98007428494853, 40.64053969984795],
      [-73.98000693002487, 40.6402088377546],
      [-73.97990983138484, 40.63968635791175],
      [-73.97987360298706, 40.639518205950424],
      [-73.9796770495655, 40.63846479981803],
      [-73.97955441162159, 40.63781925969067],
      [-73.97947592089827, 40.63743136398443],
      [-73.97938644718404, 40.63693216348757],
      [-73.97928591736762, 40.636414194191275],
      [-73.9791118873775, 40.63544038643937],
      [-73.97802158944135, 40.63555270290522],
      [-73.9768886114649, 40.635674862028225],
      [-73.97663656021153, 40.63435382127075],
      [-73.97655064148618, 40.633903509144076],
      [-73.97643342179832, 40.63328912259067],
      [-73.97604935657381, 40.631275905646774]
    ]
  ]
}
"""

    static let sampleMultiPolygon = """
{
  "type": "MultiPolygon",
  "coordinates": [
    [
      [
        [102.0, 2.0],
        [103.0, 2.0],
        [103.0, 3.0],
        [102.0, 3.0],
        [102.0, 2.0]
      ]
    ],
    [
      [
        [100.0, 0.0],
        [101.0, 0.0],
        [101.0, 1.0],
        [100.0, 1.0],
        [100.0, 0.0]
      ],
      [
        [100.2, 0.2],
        [100.2, 0.8],
        [100.8, 0.8],
        [100.8, 0.2],
        [100.2, 0.2]
      ]
    ]
  ]
}
"""
}
