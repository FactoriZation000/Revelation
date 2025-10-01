/*
--------------------------------------------------------------------------------

	Copyright (C) 2025 Graphics Park
	Apache License 2.0

    DepthOfFieldCommon

    Reference:[1]Guillaume Abadie, 2018, A Life of a bokeh, https://epicgames.ent.box.com/s/s86j70iamxvsuu6j35pilypficznec04
              [2]Michael Potmesil & Indranil Chakravarty, 1981, Synthetic lmage Generation with a Lens and Aperture Camera Mode, https://ftp.bioeng.auckland.ac.nz/pub/pub/jtur044/references/virtual%20environments/p85-potmesil.pdf
              [3]Jorge Jimenez, 2014, Next Generation Post Processing in Call of Duty Advanced Warfare, https://www.iryoku.com/next-generation-post-processing-in-call-of-duty-advanced-warfare/
              [4]John L. Smith, 1996, Implementing Median Filters in XC4000E FPGAS

    Thank Yongxin Mo for optimizing and modifying the code.

--------------------------------------------------------------------------------
*/

// External Settings
//#define DOF_ENABLED
//#define DOF_EXCLUDE_HAND
// Make the hand distinct(more cost)

#define DOF_SENSOR_SIZE 36.0f // [13.2f 22.3f 36.0f 43.0f 54.0f 60.0f]
// Sensor size (default full frame)

#define DOF_F_STOP 5.6f // [1.0f 1.4f 2.0f 2.8f 4.0f 5.6f 8.0f 11.0f 16.0f 22.0f 32.0f]
// F-stop

#define DOF_LENS_PARAMETER_MODE 0 // [0 1]
// Aperture diameter and focal length(0 for auto, 1 for manual)
#define DOF_LENS_FOCUS_LENGTH 30.0f // [10.0f 20.0f 30.0f 40.0f 50.0f 60.0f 70.0f 80.0f 90.0f 100.0f 110.0f 120.0f 130.0f 140.0f 150.0f 160.0f 170.0f 180.0f 190.0f 200.0f]
// Focal length
#define DOF_LENS_APERTURE_DIAMETER 6.0f // [1.0f 2.0f 3.0f 4.0f 5.0f 6.0f 7.0f 8.0f 9.0f 10.0f 11.0f 12.0f 13.0f 14.0f 15.0f 16.0f 17.0f 18.0f 19.0f 20.0f 21.0f 22.0f 23.0f 24.0f 25.0f 26.0f 27.0f 28.0f 29.0f 30.0f 31.0f 32.0f 33.0f 34.0f 35.0f 36.0f 37.0f 38.0f 39.0f 40.0f 41.0f 42.0f 43.0f 44.0f 45.0f 46.0f 47.0f 48.0f 49.0f 50.0f 51.0f 52.0f 53.0f 54.0f 55.0f 56.0f 57.0f 58.0f 59.0f 60.0f 61.0f 62.0f 63.0f 64.0f 65.0f 66.0f 67.0f 68.0f 69.0f 70.0f 71.0f 72.0f 73.0f 74.0f 75.0f 76.0f 77.0f 78.0f 79.0f 80.0f 81.0f 82.0f 83.0f 84.0f 85.0f 86.0f 87.0f 88.0f 89.0f 90.0f 91.0f 92.0f 93.0f 94.0f 95.0f 96.0f 97.0f 98.0f 99.0f 100.0f]
// Aperture diameter

#define DOF_FOCUS_MODE 0 // [0 1]
// Focus mode, 0 for auto, 1 for manual
#define DOF_MANUAL_FOCUS_DISTANCE_METERS 10.0f // [0.0f 1.0f 2.0f 3.0f 4.0f 5.0f 6.0f 7.0f 8.0f 9.0f 10.0f 11.0f 12.0f 13.0f 14.0f 15.0f 16.0f 17.0f 18.0f 19.0f 20.0f 21.0f 22.0f 23.0f 24.0f 25.0f 26.0f 27.0f 28.0f 29.0f 30.0f 31.0f 32.0f 33.0f 34.0f 35.0f 36.0f 37.0f 38.0f 39.0f 40.0f 41.0f 42.0f 43.0f 44.0f 45.0f 46.0f 47.0f 48.0f 49.0f 50.0f 51.0f 52.0f 53.0f 54.0f 55.0f 56.0f 57.0f 58.0f 59.0f 60.0f 61.0f 62.0f 63.0f 64.0f 65.0f 66.0f 67.0f 68.0f 69.0f 70.0f 71.0f 72.0f 73.0f 74.0f 75.0f 76.0f 77.0f 78.0f 79.0f 80.0f 81.0f 82.0f 83.0f 84.0f 85.0f 86.0f 87.0f 88.0f 89.0f 90.0f 91.0f 92.0f 93.0f 94.0f 95.0f 96.0f 97.0f 98.0f 99.0f 100.0f]
// Manual focus distance(m)
#define DOF_MANUAL_FOCUS_DISTANCE_DECIMETERS 0.0f // [0.0f 1.0f 2.0f 3.0f 4.0f 5.0f 6.0f 7.0f 8.0f 9.0f 10.0f 11.0f 12.0f 13.0f 14.0f 15.0f 16.0f 17.0f 18.0f 19.0f 20.0f 21.0f 22.0f 23.0f 24.0f 25.0f 26.0f 27.0f 28.0f 29.0f 30.0f 31.0f 32.0f 33.0f 34.0f 35.0f 36.0f 37.0f 38.0f 39.0f 40.0f 41.0f 42.0f 43.0f 44.0f 45.0f 46.0f 47.0f 48.0f 49.0f 50.0f 51.0f 52.0f 53.0f 54.0f 55.0f 56.0f 57.0f 58.0f 59.0f 60.0f 61.0f 62.0f 63.0f 64.0f 65.0f 66.0f 67.0f 68.0f 69.0f 70.0f 71.0f 72.0f 73.0f 74.0f 75.0f 76.0f 77.0f 78.0f 79.0f 80.0f 81.0f 82.0f 83.0f 84.0f 85.0f 86.0f 87.0f 88.0f 89.0f 90.0f 91.0f 92.0f 93.0f 94.0f 95.0f 96.0f 97.0f 98.0f 99.0f 100.0f]
// Manual focus distance(dm)
#define DOF_MANUAL_FOCUS_DISTANCE_CENTIMETERS 0.0f // [0.0f 1.0f 2.0f 3.0f 4.0f 5.0f 6.0f 7.0f 8.0f 9.0f 10.0f 11.0f 12.0f 13.0f 14.0f 15.0f 16.0f 17.0f 18.0f 19.0f 20.0f 21.0f 22.0f 23.0f 24.0f 25.0f 26.0f 27.0f 28.0f 29.0f 30.0f 31.0f 32.0f 33.0f 34.0f 35.0f 36.0f 37.0f 38.0f 39.0f 40.0f 41.0f 42.0f 43.0f 44.0f 45.0f 46.0f 47.0f 48.0f 49.0f 50.0f 51.0f 52.0f 53.0f 54.0f 55.0f 56.0f 57.0f 58.0f 59.0f 60.0f 61.0f 62.0f 63.0f 64.0f 65.0f 66.0f 67.0f 68.0f 69.0f 70.0f 71.0f 72.0f 73.0f 74.0f 75.0f 76.0f 77.0f 78.0f 79.0f 80.0f 81.0f 82.0f 83.0f 84.0f 85.0f 86.0f 87.0f 88.0f 89.0f 90.0f 91.0f 92.0f 93.0f 94.0f 95.0f 96.0f 97.0f 98.0f 99.0f 100.0f]
// Manual focus distance(cm)

#define DOF_KARIS_AVERAGE_STRENGTH 0.250f // [0.000f 0.125f 0.250f 0.500f 0.875f 1.000f]
// KarisAverage Strength

#define DOF_FOCUS_AREA_SCALE 1.0f // [0.1f 0.2f 0.3f 0.4f 0.5f 0.6f 0.7f 0.8f 0.9f 1.0f 1.1f 1.2f 1.3f 1.4f 1.5f 1.6f 1.7f 1.8f 1.9f 2.0f]
// Focus area scale factor

#define DOF_RING_COUNT 3 // [1 2 3]
// Number of sampling rings (less than or equal to 3)
#define DOF_MAXIMUM_COC 12.0f // [12.0f 12.5f 13.0f 13.5f 14.0f 14.5f 15.0f 15.5f 16.0f 16.5f 17.0f 17.5f 18.0f 18.5f 19.0f 19.5f 20.0f]
// Maximum COC (in pixels)

//#define DOF_COLOR_ABERRATION
// Enable CA
#define DOF_COLOR_ABERRATION_FACTOR 0.005f // [0.005f 0.010f 0.015f 0.020f 0.025f 0.030f 0.035f 0.040f 0.045f 0.050f 0.055f 0.060f 0.065f 0.070f 0.075f 0.080f 0.085f 0.090f 0.095f 0.100f]
// Recommended value:0.005f or below
#define DOF_COLOR_ABERRATION_MAX_OFFSET 0.0050f // [0.0010f 0.0015f 0.0020f 0.0025f 0.0030f 0.0035f 0.0040f 0.0045f 0.0050f 0.0055f 0.0060f 0.0065f 0.0070f 0.0075f 0.0080f 0.0085f 0.0090f 0.0095f 0.0100f]
// Recommended value:0.0020 or below

//#define DOF_CAT_EYE_EFFECT
// Enable Cat's eyes effect
#define DOF_CAT_EYE_EFFECT_RADIAL_STRENGTH 0.5f // [0.1f 0.2f 0.3f 0.4f 0.5f 0.6f 0.7f 0.8f 0.9f 1.0f 1.1f 1.2f 1.3f 1.4f 1.5f 1.6f 1.7f 1.8f 1.9f 2.0f]
// Recommended value:2.0f or below
#define DOF_CAT_EYE_EFFECT_TANGENT_STRENGTH 1.0f // [0.1f 0.2f 0.3f 0.4f 0.5f 0.6f 0.7f 0.8f 0.9f 1.0f 1.1f 1.2f 1.3f 1.4f 1.5f 1.6f 1.7f 1.8f 1.9f 2.0f]
// Recommended value:2.0f or below

#define DOF_FOCUS_POSITION_X 0.5f // [0.1f 0.2f 0.3f 0.4f 0.5f 0.6f 0.7f 0.8f 0.9f 1.0f]
#define DOF_FOCUS_POSITION_Y 0.5f // [0.1f 0.2f 0.3f 0.4f 0.5f 0.6f 0.7f 0.8f 0.9f 1.0f]
//#define DOF_FOCUS_POINT_VISIBILITY

//#define DOF_HEXAGONAL_BOKEH
// Some effect(such as Cat's eyes effect) may not perform as good as circular bokeh.

// Internal Settings(Unless you know what you are doing, do not change these settings)
#define DOF_TILE_SIZE 8
#define DOF_SPREAD_TOE_POWER 2.0f
#define DOF_DEPTH_SCALE_FOREGROUND (far * 1.5)
#define DOF_SINGLE_PIXEL_RADIUS 0.7071f
// #define DOF_SINGLE_PIXEL_RADIUS 0.3535f
// length(vec2(0.5, 0.5)), half of a pixel's diagonal
// the maximum of SampleAlpha is 0.6366

float SafeRcp(float x) { return x > 1e-6 ? rcp(x) : 0.0f; }

//  Reference:[3]
const vec2 precomputedBokehOffsets[49] = vec2[49]
(
    // === Center (1 point) ===
    vec2( 0.00000f,  0.00000f),

    // === Ring 1 (8 points, 45° spacing) ===
    vec2( 1.00000f,  0.00000f),
    vec2( 0.70711f,  0.70711f),
    vec2( 0.00000f,  1.00000f),
    vec2(-0.70711f,  0.70711f),
    vec2(-1.00000f,  0.00000f),
    vec2(-0.70711f, -0.70711f),
    vec2( 0.00000f, -1.00000f),
    vec2( 0.70711f, -0.70711f),

    // === Ring 2 (16 points, 22.5° spacing) ===
    vec2( 1.00000f,  0.00000f),
    vec2( 0.92388f,  0.38268f),
    vec2( 0.70711f,  0.70711f),
    vec2( 0.38268f,  0.92388f),
    vec2( 0.00000f,  1.00000f),
    vec2(-0.38268f,  0.92388f),
    vec2(-0.70711f,  0.70711f),
    vec2(-0.92388f,  0.38268f),
    vec2(-1.00000f,  0.00000f),
    vec2(-0.92388f, -0.38268f),
    vec2(-0.70711f, -0.70711f),
    vec2(-0.38268f, -0.92388f),
    vec2( 0.00000f, -1.00000f),
    vec2( 0.38268f, -0.92388f),
    vec2( 0.70711f, -0.70711f),
    vec2( 0.92388f, -0.38268f),

    // === Ring 3 (24 points, 15° spacing) ===
    vec2( 1.00000f,  0.00000f),
    vec2( 0.96593f,  0.25882f),
    vec2( 0.86603f,  0.50000f),
    vec2( 0.70711f,  0.70711f),
    vec2( 0.50000f,  0.86603f),
    vec2( 0.25882f,  0.96593f),
    vec2( 0.00000f,  1.00000f),
    vec2(-0.25882f,  0.96593f),
    vec2(-0.50000f,  0.86603f),
    vec2(-0.70711f,  0.70711f),
    vec2(-0.86603f,  0.50000f),
    vec2(-0.96593f,  0.25882f),
    vec2(-1.00000f,  0.00000f),
    vec2(-0.96593f, -0.25882f),
    vec2(-0.86603f, -0.50000f),
    vec2(-0.70711f, -0.70711f),
    vec2(-0.50000f, -0.86603f),
    vec2(-0.25882f, -0.96593f),
    vec2( 0.00000f, -1.00000f),
    vec2( 0.25882f, -0.96593f),
    vec2( 0.50000f, -0.86603f),
    vec2( 0.70711f, -0.70711f),
    vec2( 0.86603f, -0.50000f),
    vec2( 0.96593f, -0.25882f)
);

// const vec2 hexprecomputedBokehOffsets[61] = vec2[61](
//     // === Center (1 point) ===
//     vec2( 0.00000f,  0.00000f),

//     // === Ring 1 (12 points) ===
//     vec2( 0.33333f,  0.00000f),
//     vec2( 0.25000f,  0.14434f),
//     vec2( 0.16667f,  0.28868f),
//     vec2( 0.00000f,  0.28868f),
//     vec2(-0.16667f,  0.28868f),
//     vec2(-0.25000f,  0.14434f),
//     vec2(-0.33333f,  0.00000f),
//     vec2(-0.25000f, -0.14434f),
//     vec2(-0.16667f, -0.28868f),
//     vec2( 0.00000f, -0.28868f),
//     vec2( 0.16667f, -0.28868f),
//     vec2( 0.25000f, -0.14434f),

//     // === Ring 2 (24 points) ===
//     vec2( 0.66667f,  0.00000f),
//     vec2( 0.58333f,  0.14434f),
//     vec2( 0.50000f,  0.28868f),
//     vec2( 0.41667f,  0.43301f),
//     vec2( 0.33333f,  0.57735f),
//     vec2( 0.16667f,  0.57735f),
//     vec2( 0.00000f,  0.57735f),
//     vec2(-0.16667f,  0.57735f),
//     vec2(-0.33333f,  0.57735f),
//     vec2(-0.41667f,  0.43301f),
//     vec2(-0.50000f,  0.28868f),
//     vec2(-0.58333f,  0.14434f),
//     vec2(-0.66667f,  0.00000f),
//     vec2(-0.58333f, -0.14434f),
//     vec2(-0.50000f, -0.28868f),
//     vec2(-0.41667f, -0.43301f),
//     vec2(-0.33333f, -0.57735f),
//     vec2(-0.16667f, -0.57735f),
//     vec2( 0.00000f, -0.57735f),
//     vec2( 0.16667f, -0.57735f),
//     vec2( 0.33333f, -0.57735f),
//     vec2( 0.41667f, -0.43301f),
//     vec2( 0.50000f, -0.28868f),
//     vec2( 0.58333f, -0.14434f),

//     // === Ring 3 (24 points) ===
//     vec2( 1.00000f,  0.00000f),
//     vec2( 0.87500f,  0.21651f),
//     vec2( 0.75000f,  0.43301f),
//     vec2( 0.62500f,  0.64952f),
//     vec2( 0.50000f,  0.86603f),
//     vec2( 0.25000f,  0.86603f),
//     vec2( 0.00000f,  0.86603f),
//     vec2(-0.25000f,  0.86603f),
//     vec2(-0.50000f,  0.86603f),
//     vec2(-0.62500f,  0.64952f),
//     vec2(-0.75000f,  0.43301f),
//     vec2(-0.87500f,  0.21651f),
//     vec2(-1.00000f,  0.00000f),
//     vec2(-0.87500f, -0.21651f),
//     vec2(-0.75000f, -0.43301f),
//     vec2(-0.62500f, -0.64952f),
//     vec2(-0.50000f, -0.86603f),
//     vec2(-0.25000f, -0.86603f),
//     vec2( 0.00000f, -0.86603f),
//     vec2( 0.25000f, -0.86603f),
//     vec2( 0.50000f, -0.86603f),
//     vec2( 0.62500f, -0.64952f),
//     vec2( 0.75000f, -0.43301f),
//     vec2( 0.87500f, -0.21651f)
// );

const vec2 hexprecomputedBokehOffsets[37] = vec2[37]
(
    // === Center (1 point) ===
    vec2( 0.00000f,  0.00000f),

    // === Ring 1 (6 points, 60° spacing) ===
    vec2( 0.33333f,  0.00000f),
    vec2( 0.16667f,  0.28868f),
    vec2(-0.16667f,  0.28868f),
    vec2(-0.33333f,  0.00000f),
    vec2(-0.16667f, -0.28868f),
    vec2( 0.16667f, -0.28868f),

    // === Ring 2 (12 points, 30° spacing) ===
    vec2( 0.66667f,  0.00000f),
    vec2( 0.50000f,  0.28868f),
    vec2( 0.33333f,  0.57735f),
    vec2( 0.00000f,  0.57735f),
    vec2(-0.33333f,  0.57735f),
    vec2(-0.50000f,  0.28868f),
    vec2(-0.66667f,  0.00000f),
    vec2(-0.50000f, -0.28868f),
    vec2(-0.33333f, -0.57735f),
    vec2( 0.00000f, -0.57735f),
    vec2( 0.33333f, -0.57735f),
    vec2( 0.50000f, -0.28868f),

    // === Ring 3 (18 points, 20° spacing) ===
    vec2( 1.00000f,  0.00000f),
    vec2( 0.83333f,  0.28868f),
    vec2( 0.66667f,  0.57735f),
    vec2( 0.50000f,  0.86603f),
    vec2( 0.16667f,  0.86603f),
    vec2(-0.16667f,  0.86603f),
    vec2(-0.50000f,  0.86603f),
    vec2(-0.66667f,  0.57735f),
    vec2(-0.83333f,  0.28868f),
    vec2(-1.00000f,  0.00000f),
    vec2(-0.83333f, -0.28868f),
    vec2(-0.66667f, -0.57735f),
    vec2(-0.50000f, -0.86603f),
    vec2(-0.16667f, -0.86603f),
    vec2( 0.16667f, -0.86603f),
    vec2( 0.50000f, -0.86603f),
    vec2( 0.66667f, -0.57735f),
    vec2( 0.83333f, -0.28868f)
);

// Reference:[4]
// The variables were numbered in order from top to bottom and left to right.
float Median9(float p1, float p2, float p3, float p4, float p5, float p6, float p7, float p8, float p9)
{

	float node1Low = min(p2, p3);
	float node1High = max(p2, p3);

	float node4Low = min(p5, p6);
	float node4High = max(p5, p6);

	float node7Low = min(p8, p9);
	float node7High = max(p8, p9);

	float node2Low = min(p1, node1Low);
	float node2High = max(p1, node1Low);

	float node5Low = min(p4, node4Low);
	float node5High = max(p4, node4Low);

	float node8Low = min(p7, node7Low);
	float node8High = max(p7, node7Low);

	float node3Low = min(node1High, node2High);
	float node3High = max(node1High, node2High);

	float node6Low = min(node4High, node5High);
	float node6High = max(node4High, node5High);

	float node9Low = min(node7High, node8High);
	float node9High = max(node7High, node8High);

	float node10High = max(node2Low, node5Low);
	float node11Low = min(node6High, node9High);

	float node12High = max(node10High, node8Low);
	float node16Low = min(node3High, node11Low);

	float node13High = max(node6Low, node9Low);
	float node13Low = min(node6Low, node9Low);

	float node14High = max(node3Low, node13Low);
	float node15Low = min(node13High, node14High);

	float node17High = max(node15Low, node16Low);
	float node17Low = min(node15Low, node16Low);

	float node18High = max(node12High, node17Low);
	float median = min(node17High, node18High);

	return median;
}

float Max9(float p1, float p2, float p3, float p4, float p5, float p6, float p7, float p8, float p9)
{
    return max(max(max(p1, p2), max(p3, p4)), max(max(p5, p6), max(max(p7, p8), p9)));
}

const ivec2 filterOffsets[9] = ivec2[9]
(
    ivec2(-1, -1), ivec2( 0, -1), ivec2( 1, -1),
    ivec2(-1,  0), ivec2( 0,  0), ivec2( 1,  0),
    ivec2(-1,  1), ivec2( 0,  1), ivec2( 1,  1)
);

const vec2 circularFilterOffsets[9] = vec2[9](
    vec2(-1.00000f,  0.00000f), vec2(-0.70711f, -0.70711f), vec2(0.00000f, -1.00000f),
    vec2( 0.70711f, -0.70711f), vec2( 0.00000f,  0.00000f), vec2(0.70711f,  0.70711f),
    vec2( 0.00000f,  1.00000f), vec2(-0.70711f,  0.70711f), vec2(1.00000f,  0.00000f)
);

// Reference:[3][4]
vec3 MedianFilter3x3(sampler2D s, ivec2 texelCoord)
{

    vec3 p1 = texelFetch(s, texelCoord + filterOffsets[0], 0).rgb;
    vec3 p2 = texelFetch(s, texelCoord + filterOffsets[1], 0).rgb;
    vec3 p3 = texelFetch(s, texelCoord + filterOffsets[2], 0).rgb;
    vec3 p4 = texelFetch(s, texelCoord + filterOffsets[3], 0).rgb;
    vec3 p5 = texelFetch(s, texelCoord + filterOffsets[4], 0).rgb;
    vec3 p6 = texelFetch(s, texelCoord + filterOffsets[5], 0).rgb;
    vec3 p7 = texelFetch(s, texelCoord + filterOffsets[6], 0).rgb;
    vec3 p8 = texelFetch(s, texelCoord + filterOffsets[7], 0).rgb;
    vec3 p9 = texelFetch(s, texelCoord + filterOffsets[8], 0).rgb;

    float R = Median9(p1.r, p2.r, p3.r, p4.r, p5.r, p6.r, p7.r, p8.r, p9.r);
    float G = Median9(p1.g, p2.g, p3.g, p4.g, p5.g, p6.g, p7.g, p8.g, p9.g);
    float B = Median9(p1.b, p2.b, p3.b, p4.b, p5.b, p6.b, p7.b, p8.b, p9.b);

    return vec3(R, G, B);
}

vec3 MaxFilter3x3(sampler2D s, ivec2 texelCoord)
{

    vec3 p1 = texelFetch(s, texelCoord + filterOffsets[0], 0).rgb;
    vec3 p2 = texelFetch(s, texelCoord + filterOffsets[1], 0).rgb;
    vec3 p3 = texelFetch(s, texelCoord + filterOffsets[2], 0).rgb;
    vec3 p4 = texelFetch(s, texelCoord + filterOffsets[3], 0).rgb;
    vec3 p5 = texelFetch(s, texelCoord + filterOffsets[4], 0).rgb;
    vec3 p6 = texelFetch(s, texelCoord + filterOffsets[5], 0).rgb;
    vec3 p7 = texelFetch(s, texelCoord + filterOffsets[6], 0).rgb;
    vec3 p8 = texelFetch(s, texelCoord + filterOffsets[7], 0).rgb;
    vec3 p9 = texelFetch(s, texelCoord + filterOffsets[8], 0).rgb;

    float R = Max9(p1.r, p2.r, p3.r, p4.r, p5.r, p6.r, p7.r, p8.r, p9.r);
    float G = Max9(p1.g, p2.g, p3.g, p4.g, p5.g, p6.g, p7.g, p8.g, p9.g);
    float B = Max9(p1.b, p2.b, p3.b, p4.b, p5.b, p6.b, p7.b, p8.b, p9.b);

    return vec3(R, G, B);
}


// Reference:[3]
// Very important
float SampleAlpha(float sampleCoc)
{
	return min(rcp(PI * sampleCoc * sampleCoc), rcp(PI * DOF_SINGLE_PIXEL_RADIUS * DOF_SINGLE_PIXEL_RADIUS));
}

vec2 DepthCmp2(float depth, float minTileDepth)
{
	float d = DOF_DEPTH_SCALE_FOREGROUND * (depth - minTileDepth);

	vec2 depthCmp = vec2(0.0f);
	depthCmp.x = smoothstep(0.0f, 1.0f, d); // Background
	depthCmp.y = 1.0 - depthCmp.x; // Foreground

	return depthCmp;
}

float SpreadToe(float offsetCoc, float spreadCmp)
{
	return offsetCoc <= 1.0f ? pow(spreadCmp, DOF_SPREAD_TOE_POWER) : spreadCmp;
}
float SpreadCmp(float offsetCoc, float sampleCoc, float spreadScale)
{
	return SpreadToe(offsetCoc, saturate(spreadScale * sampleCoc - offsetCoc + 1.0));
}

float KarisAverage(in vec3 color) {
    return SafeRcp(1.0f + (1.0f - DOF_KARIS_AVERAGE_STRENGTH) * luminance(color));
}

float TemporalIGN(vec2 p, float time)
{
    vec3 magic = vec3(0.06711056f, 0.00583715f, 52.9829189f);
    vec3 pt = vec3(p, time);
    vec3 magic3d = vec3(0.06711056f, 0.00583715f, 0.07216593f);
    return fract(magic.z * fract(dot(pt, magic3d)));
}

float TemporalIGN(vec2 p, float seed, float time)
{
    vec3 magic = vec3(0.06711056f, 0.00583715f, 52.9829189f);
    vec3 pt = vec3(p, time);
    vec3 magic3d = vec3(0.06711056f, 0.00583715f, 0.07216593f);

    float seedHash = fract(sin(seed * 91.3458f) * 47453.5453f);

    return fract(magic.z * fract(dot(pt, magic3d) + seedHash));
}

// Known Problem：
// 边缘锯齿
// 亮物体边缘产生bokeh


