package builders;

import libnoise.model.Sphere;
import libnoise.builder.NoiseMapBuilderCylinder;
import libnoise.model.Cylinder;

/**
 Builds a cylindrical noise map.

 This class builds a noise map by filling it with coherent-noise values
 generated from the surface of a cylinder.

 This class describes these input values using an (angle, height)
 coordinate system.  After generating the coherent-noise value from the
 input value, it then "flattens" these coordinates onto a plane so that
 it can write the values into a two-dimensional noise map.

 The cylinder model has a radius of 1.0 unit and has infinite height.
 The cylinder is oriented along the @a y axis.  Its center is at the
 origin.

 The x coordinate in the noise map represents the angle around the
 cylinder's y axis.  The y coordinate in the noise map represents the
 height above the x-z plane.

 The application must provide the lower and upper angle bounds of the
 noise map, in degrees, and the lower and upper height bounds of the
 noise map, in units.
 **/
class NoiseMapBuilderCylinderByRow extends NoiseMapBuilderCylinder implements IRowBuilder{

    @:isVar public var curRow(default, null) = 0;

    var cylinder : Cylinder;
    var angleExtent : Float;
    var heightExtent : Float;
    var xDelta : Float;
    var yDelta : Float;
    var curAngle : Float;
    var curHeight : Float;

    public function new() { super(); }

    public function initialize():Void {
        cylinder = new Cylinder(sourceModule);
        angleExtent = upperAngleBound - lowerAngleBound;
        heightExtent = upperHeightBound - lowerHeightBound;
        xDelta = angleExtent / destWidth;
        yDelta = heightExtent / destHeight;
        curAngle = lowerAngleBound;
        curHeight = lowerHeightBound;
    }

    public function buildNext() {
        if ( upperAngleBound <= lowerAngleBound
        || upperHeightBound <= lowerHeightBound
        || destWidth <= 0
        || destHeight <= 0
        || sourceModule == null
        || destNoiseMap == null)
            throw 'Invalid parameter';

        if(curRow >= destHeight) return true;
        if(curRow == 0) initialize();
        curHeight = lowerHeightBound + curRow * yDelta;

        curAngle = lowerAngleBound;
        for(x in 0...destWidth){
            var curValue = cylinder.getValue(curAngle, curHeight);
            this.destNoiseMap.setValue(x,curRow,curValue);
            curAngle += xDelta;
        }
        if(callback != null)
            callback(curRow);
        curRow++;
        return false;
    }
}