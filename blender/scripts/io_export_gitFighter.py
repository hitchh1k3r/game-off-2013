bl_info = {
    "name": "Export: gitFighter (.json)",
    "description": "Export meshs as a single object for gitFighter to load",
    "author": "HitchH1k3r",
    "version": (0, 1, 0),
    "blender": (2, 62, 0),
    "location": "File > Export > gitFighter (.json)",
    "warning": "",
    "wiki_url": "",
    "tracker_url": "",
    "category": "Import-Export",
    }

import bpy

def main(filepath):
    bpy.ops.object.mode_set(mode='OBJECT')
    out = open(filepath, 'w')
    obs = bpy.data.objects
    out.write( '{\n' )
    out.write( '  "box" : { "length" : 0.0, "width" : 0.0, "height" : 0.0, "originX" : 0.0, "originY" : 0.0, "originZ" : 0.0 },\n' )
    out.write( '  "shape" : { "color" : [ 1.0, 1.0, 1.0], "vertices" : [ 0.0, 0.0, 0.0 ] },\n' )
    out.write( '  "sprite" : { "sheet" : "sprites.png", "left" : 0.0, "top" : 0.0, "right" : 0.0, "bottom" : 0.0},\n' )
    out.write( '  "materials" : [ ' )
    firstMaterial = True
    for ob in obs:
        if ob.type == 'MESH':
            mesh = bpy.data.meshes[ob.name]
            if firstMaterial:
                firstMaterial = False
            else:
                out.write( ', ' )
            out.write( '{ "numindices" : %i, "diffuse" : "textures/%s-diff.png", "emissive" : "textures/%s-em.png" }' % ((len(mesh.polygons) * 3), mesh.name, mesh.name) )
    out.write( ' ],\n' )

    out.write('  "indices" : [ ')
    firstIndex = True
    for ob in obs:
        if ob.type == 'MESH':
            mesh = bpy.data.meshes[ob.name]
            for poly in mesh.polygons:
                if firstIndex:
                    firstIndex = False
                else:
                    out.write( ', ' )
                out.write( '%i, %i, %i' % (poly.vertices[0], poly.vertices[1], poly.vertices[2]) )
    out.write( ' ],\n' )

    out.write('  "vertexPositions" : [ ')
    firstPosition = True
    for ob in obs:
        if ob.type == 'MESH':
            mw = ob.matrix_world
            mesh = bpy.data.meshes[ob.name]
            for vert in mesh.vertices:
                if firstPosition:
                    firstPosition = False
                else:
                    out.write( ', ' )
                out.write( '%f, %f, %f' % ((mw * vert.co).x, (mw * vert.co).y, (mw * vert.co).z) )
    out.write( ' ],\n' )

    out.write('  "vertexNormals" : [ ')
    firstNormal = True
    for ob in obs:
        if ob.type == 'MESH':
            mesh = bpy.data.meshes[ob.name]
            for vert in mesh.vertices:
                if firstNormal:
                    firstNormal = False
                else:
                    out.write( ', ' )
                out.write( '%f, %f, %f' % (vert.normal.x, vert.normal.y, vert.normal.z) )
    out.write( ' ],\n' )

    out.write('  "vertexTextureCoords" : [ ')
    firstTexture = True
    for ob in obs:
        if ob.type == 'MESH':
            mesh = bpy.data.meshes[ob.name]
            uvs = [None]*len(mesh.vertices);
            for loop in mesh.loops:
                uvs[loop.vertex_index] = mesh.uv_layers.active.data[loop.index].uv
            for vert in mesh.vertices:
                if firstTexture:
                    firstTexture = False
                else:
                    out.write( ', ' )
                out.write( '%f, %f' % (uvs[vert.index].x, 1-uvs[vert.index].y) )
    out.write( ' ]\n' )

    out.write( '}' )
    out.close()
    print ("\nExport to gitFighter json File Complete!")
    return {'FINISHED'}

from bpy.props import StringProperty

class GitFighterExporter(bpy.types.Operator):
    bl_idname = "export.json"
    bl_label = "Export to gitFighter JSON"
    filename_ext = ".json"
    filter_glob = StringProperty(default="*.json", options={'HIDDEN'})
    filepath = StringProperty(subtype='FILE_PATH')

    def execute(self, context):
        return main(self.filepath)

    def invoke(self, context, event):
        if not self.filepath:
            self.filepath = bpy.path.ensure_ext(bpy.data.filepath, ".json")
        WindowManager = context.window_manager
        WindowManager.fileselect_add(self)
        return {"RUNNING_MODAL"}

def menu_func(self, context):
    self.layout.operator(GitFighterExporter.bl_idname, text="gitFighter (.json)")


def register():
    bpy.utils.register_class(GitFighterExporter)
    bpy.types.INFO_MT_file_export.append(menu_func)


def unregister():
    bpy.utils.unregister_class(GitFighterExporter)
    bpy.types.INFO_MT_file_export.remove(menu_func)

if __name__ == "__main__":
    register()