package builders;

/// Builds a planar noise map.
///
/// This class builds a noise map by filling it with coherent-noise values
/// generated from the surface of a plane.
///
/// This class describes these input values using (x, z) coordinates.
/// Their y coordinates are always 0.0.
///
/// The application must provide the lower and upper x coordinate bounds
/// of the noise map, in units, and the lower and upper z coordinate
/// bounds of the noise map, in units.
///
/// To make a tileable noise map with no seams at the edges, call the
/// EnableSeamless() method.
import libnoise.builder.NoiseMapBuilderPlane;
import libnoise.Utils;
import libnoise.model.Plane;
class NoiseMapBuilderPlaneByRow  extends NoiseMapBuilderPlane implements IRowBuilder{

    @:isVar public var curRow(default, null) = 0;

    var plane : Plane;
    var xExtent : Float;
    var zExtent : Float;
    var xDelta : Float;
    var zDelta : Float;
    var xCur    : Float;
    var zCur    : Float;

    public function new() { super(); }

    public function initialize():Void {
        plane   = new Plane(sourceModule);
        xExtent = upperXBound - lowerXBound;
        zExtent = upperZBound - lowerZBound;
        xDelta  = xExtent / destWidth;
        zDelta  = zExtent / destHeight;
        xCur    = lowerXBound;
        zCur    = lowerZBound;
    }

    public function buildNext() {
        if ( upperXBound <= lowerXBound
        || upperZBound <= lowerZBound
        || destWidth <= 0
        || destHeight <= 0
        || sourceModule == null
        || destNoiseMap == null)
            throw 'Invalid parameter';

        if(curRow >= destHeight) return true;
        if(curRow == 0) initialize();
        zCur = curRow * zDelta;

        xCur = lowerXBound;
        for(x in 0...destWidth){
            var curValue : Float;
            if(!isSeamlessEnabled)
                curValue = plane.getValue(x, curRow);
            else{
                var swValue = plane.getValue (xCur          , zCur          );
                var seValue = plane.getValue (xCur + xExtent, zCur          );
                var nwValue = plane.getValue (xCur          , zCur + zExtent);
                var neValue = plane.getValue (xCur + xExtent, zCur + zExtent);
                var xBlend = 1.0 - ((xCur - lowerXBound) / xExtent);
                var zBlend = 1.0 - ((zCur - lowerZBound) / zExtent);
                var z0 = Utils.InterpolateLinear(swValue, seValue, xBlend);
                var z1 = Utils.InterpolateLinear(nwValue, neValue, xBlend);
                curValue = Utils.InterpolateLinear(z0, z1, zBlend);
            }
            this.destNoiseMap.setValue(x,curRow,curValue);
            xCur += xDelta;
        }
        if(callback != null)
            callback(curRow);

        curRow++;
        return false;
    }
}