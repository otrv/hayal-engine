pub const Vec2 = @Vector(2, f32);
pub const Vec3 = @Vector(3, f32);
pub const Vec4 = @Vector(4, f32);

pub fn dot3(a: Vec3, b: Vec3) f32 {
    const p = a * b;
    return p[0] + p[1] + p[2];
}

pub fn length3(v: Vec3) f32 {
    return @sqrt(dot3(v, v));
}

pub fn normalize3(v: Vec3) Vec3 {
    const inv: Vec3 = @splat(1.0 / length3(v));
    return v * inv;
}

pub fn cross3(a: Vec3, b: Vec3) Vec3 {
    return .{
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    };
}

/// Column-major: `Mat4[c]` is column `c`.
pub const Mat4 = [4]Vec4;

pub const identity: Mat4 = .{
    .{ 1, 0, 0, 0 },
    .{ 0, 1, 0, 0 },
    .{ 0, 0, 1, 0 },
    .{ 0, 0, 0, 1 },
};

pub fn mulMat4(a: Mat4, b: Mat4) Mat4 {
    var r: Mat4 = undefined;
    inline for (0..4) |j| {
        const bx: Vec4 = @splat(b[j][0]);
        const by: Vec4 = @splat(b[j][1]);
        const bz: Vec4 = @splat(b[j][2]);
        const bw: Vec4 = @splat(b[j][3]);
        r[j] = bx * a[0] + by * a[1] + bz * a[2] + bw * a[3];
    }
    return r;
}

pub fn mulMat4Vec4(m: Mat4, v: Vec4) Vec4 {
    const vx: Vec4 = @splat(v[0]);
    const vy: Vec4 = @splat(v[1]);
    const vz: Vec4 = @splat(v[2]);
    const vw: Vec4 = @splat(v[3]);
    return vx * m[0] + vy * m[1] + vz * m[2] + vw * m[3];
}

pub fn translate(m: Mat4, v: Vec3) Mat4 {
    const vx: Vec4 = @splat(v[0]);
    const vy: Vec4 = @splat(v[1]);
    const vz: Vec4 = @splat(v[2]);
    return .{
        m[0],
        m[1],
        m[2],
        m[0] * vx + m[1] * vy + m[2] * vz + m[3],
    };
}

pub fn scale(m: Mat4, v: Vec3) Mat4 {
    const vx: Vec4 = @splat(v[0]);
    const vy: Vec4 = @splat(v[1]);
    const vz: Vec4 = @splat(v[2]);
    return .{
        m[0] * vx,
        m[1] * vy,
        m[2] * vz,
        m[3],
    };
}

pub fn rotate(m: Mat4, angle: f32, axis: Vec3) Mat4 {
    const a = normalize3(axis);
    const c = @cos(angle);
    const s = @sin(angle);
    const t = 1 - c;

    const r0: Vec4 = .{
        c + t * a[0] * a[0],
        t * a[0] * a[1] + s * a[2],
        t * a[0] * a[2] - s * a[1],
        0,
    };
    const r1: Vec4 = .{
        t * a[1] * a[0] - s * a[2],
        c + t * a[1] * a[1],
        t * a[1] * a[2] + s * a[0],
        0,
    };
    const r2: Vec4 = .{
        t * a[2] * a[0] + s * a[1],
        t * a[2] * a[1] - s * a[0],
        c + t * a[2] * a[2],
        0,
    };

    const r0x: Vec4 = @splat(r0[0]);
    const r0y: Vec4 = @splat(r0[1]);
    const r0z: Vec4 = @splat(r0[2]);
    const r1x: Vec4 = @splat(r1[0]);
    const r1y: Vec4 = @splat(r1[1]);
    const r1z: Vec4 = @splat(r1[2]);
    const r2x: Vec4 = @splat(r2[0]);
    const r2y: Vec4 = @splat(r2[1]);
    const r2z: Vec4 = @splat(r2[2]);

    return .{
        m[0] * r0x + m[1] * r0y + m[2] * r0z,
        m[0] * r1x + m[1] * r1y + m[2] * r1z,
        m[0] * r2x + m[1] * r2y + m[2] * r2z,
        m[3],
    };
}

pub fn ortho(left: f32, right: f32, bottom: f32, top: f32, near: f32, far: f32) Mat4 {
    const rl = right - left;
    const tb = top - bottom;
    const fn_ = far - near;
    return .{
        .{ 2 / rl, 0, 0, 0 },
        .{ 0, 2 / tb, 0, 0 },
        .{ 0, 0, -2 / fn_, 0 },
        .{
            -(right + left) / rl,
            -(top + bottom) / tb,
            -(far + near) / fn_,
            1,
        },
    };
}
