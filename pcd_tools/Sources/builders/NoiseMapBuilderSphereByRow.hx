package builders;

/**
 Builds a spherical noise map.

 This class builds a noise map by filling it with coherent-noise values
 generated from the surface of a sphere.

 This class describes these input values using a (latitude, longitude)
 coordinate system.  After generating the coherent-noise value from the
 input value, it then "flattens" these coordinates onto a plane so that
 it can write the values into a two-dimensional noise map.

 The sphere model has a radius of 1.0 unit.  Its center is at the
 origin.

 The x coordinate in the noise map represents the longitude.  The y
 coordinate in the noise map represents the latitude.

 The application must provide the southern, northern, western, and
 eastern bounds of the noise map, in degrees.
**/
import libnoise.builder.NoiseMapBuilderSphere;
import libnoise.model.Sphere;
class NoiseMapBuilderSphereByRow extends NoiseMapBuilderSphere implements IRowBuilder{

    @:isVar public var curRow(default, null) = 0;

    var sphere : Sphere;
    var lonExtent : Float;
    var latExtent : Float;
    var xDelta : Float;
    var yDelta : Float;
    var curLon : Float;
    var curLat : Float;

    public function new() { super(); }


    public function initialize():Void {
        sphere = new Sphere(sourceModule);
        lonExtent = eastLonBound - westLonBound;
        latExtent = northLatBound - southLatBound;
        xDelta = lonExtent / destWidth;
        yDelta = latExtent / destHeight;
        curLon = westLonBound;
        curLat = southLatBound;
    }

    public function buildNext() {
        if ( eastLonBound <= westLonBound
        || northLatBound <= southLatBound
        || destWidth <= 0
        || destHeight <= 0
        || sourceModule == null
        || destNoiseMap == null)
            throw 'Invalid parameter';

        if(curRow >= destHeight) return true;
        if(curRow == 0) initialize();
        curLat = southLatBound + curRow * yDelta;

        curLon = westLonBound;
        for(x in 0...destWidth){
            var curValue = sphere.getValue(curLat, curLon);
            this.destNoiseMap.setValue(x,curRow,curValue);
            curLon += xDelta;
        }
        if(callback != null)
            callback(curRow);
        curRow++;
        return false;
    }
}