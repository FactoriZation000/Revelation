#version 450 core
#extension GL_KHR_shader_subgroup_arithmetic : require
#extension GL_KHR_shader_subgroup_ballot : require

const vec2 workGroupsRender = vec2(0.25f, 0.25f);

#include "/program/post/dof/DepthOfFieldTilingNeighborhood.comp"
