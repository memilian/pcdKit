package builders;

import libnoise.builder.NoiseMap;

interface IRowBuilder {
    @:isVar public var curRow(default, null) = 0;
    public function buildNext():Bool;
}

typedef NoiseMapBuilderByRow = {
    buildNext : Void -> Bool,
    destNoiseMap : NoiseMap,
    callback : Int -> Void,
    curRow : Int
};