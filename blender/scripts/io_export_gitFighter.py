bl_info = {
    "name": "Export: gitFighter (.json)",
    "description": "Export meshs as a single object for gitFighter to load",
    "author": "HitchH1k3r",
    "version": (1, 0, 0),
    "location": "File > Export > gitFighter (.json)",
    "category": "Import-Export",
    }

import bpy

def main(filepath):
    bpy.ops.object.mode_set(mode='OBJECT')
    out = open(filepath, 'w')
    obs = bpy.data.objects
    materials = []
    for ob in obs:
        if ob.type == 'MESH':
            mw = ob.matrix_world
            mesh = bpy.data.meshes[ob.name]
            indices = []
            positions = []
            normals = []
            for vert in mesh.vertices:
                positions.append(mw * vert.co)
                normals.append(vert.normal)
            texCoords = [None] * len(positions)
            uvStore = [None] * len(positions)
            for poly in mesh.polygons:
                for i in range(3):
                    print('%i %i %i %i' % (poly.index, i, poly.vertices[i], poly.loop_indices[i]))
                    indexSet = False
                    newUV = mesh.uv_layers.active.data[poly.loop_indices[i]].uv
                    if uvStore[poly.vertices[i]] == None:
                        uvStore[poly.vertices[i]] = [[newUV, poly.vertices[i]]]
                        indices.append(poly.vertices[i])
                        texCoords[poly.vertices[i]] = newUV
                        indexSet = True
                    if not indexSet:
                        for oldUV in uvStore[poly.vertices[i]]:
                            if oldUV[0] == newUV:
                                indices.append(oldUV[1])
                                indexSet = True
                    if not indexSet:
                        vert = mesh.vertices[poly.vertices[i]]
                        positions.append(mw * vert.co)
                        normals.append(vert.normal)
                        texCoords.append(newUV)
                        indices.append(len(texCoords)-1)
                        uvStore[poly.vertices[i]].append([newUV, len(texCoords)-1])
            materials.append([mesh.name, indices, positions, normals, texCoords])

    out.write( '{\n' )
    out.write( '  "box" : { "length" : 0.0, "width" : 0.0, "height" : 0.0, "originX" : 0.0, "originY" : 0.0, "originZ" : 0.0 },\n' )
    out.write( '  "shape" : { "color" : [ 1.0, 1.0, 1.0], "vertices" : [ 0.0, 0.0, 0.0 ] },\n' )
    out.write( '  "sprite" : { "sheet" : "textures/sprites.png", "left" : 0.0, "top" : 0.0, "right" : 0.0, "bottom" : 0.0},\n' )
    out.write( '  "materials" : [ ' )
    firstMaterial = True
    for material in materials:
        if firstMaterial:
            firstMaterial = False
        else:
            out.write( ', ' )
        out.write( '{ "numindices" : %i, "diffuse" : "textures/%s-diff.png", "emissive" : "textures/%s-em.png" }' % (len(material[1]), material[0], material[0]) )
    out.write( ' ],\n' )


    out.write('  "indices" : [ ')
    firstIndex = True
    indexOffset = 0
    for material in materials:
        for index in material[1]:
            if firstIndex:
                firstIndex = False
            else:
                out.write( ', ' )
            out.write( str(index + indexOffset) )
        indexOffset += len(material[2])
    out.write( ' ],\n' )

    out.write('  "vertexPositions" : [ ')
    firstPosition = True
    for material in materials:
        for pos in material[2]:
            if firstPosition:
                firstPosition = False
            else:
                out.write( ', ' )
            out.write( '%f, %f, %f' % (pos.x, pos.y, pos.z) )
    out.write( ' ],\n' )

    out.write('  "vertexNormals" : [ ')
    firstNormal = True
    for material in materials:
        for normal in material[3]:
            if firstNormal:
                firstNormal = False
            else:
                out.write( ', ' )
            out.write( '%f, %f, %f' % (normal.x, normal.y, normal.z) )
    out.write( ' ],\n' )

    out.write('  "vertexTextureCoords" : [ ')
    firstTexture = True
    for material in materials:
        for uv in material[4]:
            if firstTexture:
                firstTexture = False
            else:
                out.write( ', ' )
            out.write( '%f, %f' % (uv.x, 1 - uv.y) )
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