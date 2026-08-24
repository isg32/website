<script lang="ts">
	import { onMount } from 'svelte';

	let canvasEl: HTMLCanvasElement;

	onMount(() => {
		const canvas = canvasEl;

		function syncSize() {
			const w = canvas.clientWidth || 1280;
			const h = canvas.clientHeight || 720;
			if (canvas.width !== w || canvas.height !== h) {
				canvas.width = w;
				canvas.height = h;
			}
		}

		let resizeObserver: ResizeObserver | undefined;
		if (typeof ResizeObserver !== 'undefined') {
			resizeObserver = new ResizeObserver(syncSize);
			resizeObserver.observe(canvas);
		}
		syncSize();

		const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
		if (!gl) return;
		const glContext = gl as WebGLRenderingContext;

		const vs = `attribute vec2 a_position;
varying vec2 v_texCoord;
void main() {
  v_texCoord = a_position * 0.5 + 0.5;
  gl_Position = vec4(a_position, 0.0, 1.0);
}`;
		const fs = `precision highp float;

varying vec2 v_texCoord;
uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void main() {
    vec2 uv = v_texCoord;
    vec2 p = (uv - 0.5) * 2.0;
    float aspect = u_resolution.x / u_resolution.y;
    p.x *= aspect;

    vec3 color = vec3(0.976, 0.976, 0.976);

    for(float i = 0.0; i < 40.0; i++) {
        float h = hash(vec2(i, 1.23));
        float speed = 0.2 + h * 0.3;
        float size = 0.005 + h * 0.015;

        // Spread across the full aspect-scaled width, same as p, so the
        // rising bubbles cover the whole screen instead of only a fixed
        // band down the middle on wide viewports.
        float x_pos = (h - 0.5) * 2.5 * aspect;

        float y_pos = fract(h * 10.0 + u_time * speed) * 2.5 - 1.25;

        x_pos += sin(u_time * 2.0 + h * 10.0) * 0.05;

        vec2 bubble_p = vec2(x_pos, y_pos);
        float dist = length(p - bubble_p);

        float mask = smoothstep(size, size - 0.002, dist);
        color = mix(color, vec3(0.1, 0.1, 0.1), mask * (0.4 + h * 0.4));
    }

    gl_FragColor = vec4(color, 1.0);
}`;

		function compileShader(type: number, src: string) {
			const s = glContext.createShader(type)!;
			glContext.shaderSource(s, src);
			glContext.compileShader(s);
			return s;
		}

		const prog = glContext.createProgram()!;
		glContext.attachShader(prog, compileShader(glContext.VERTEX_SHADER, vs));
		glContext.attachShader(prog, compileShader(glContext.FRAGMENT_SHADER, fs));
		glContext.linkProgram(prog);
		glContext.useProgram(prog);

		const buf = glContext.createBuffer();
		glContext.bindBuffer(glContext.ARRAY_BUFFER, buf);
		glContext.bufferData(
			glContext.ARRAY_BUFFER,
			new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]),
			glContext.STATIC_DRAW
		);
		const posLoc = glContext.getAttribLocation(prog, 'a_position');
		glContext.enableVertexAttribArray(posLoc);
		glContext.vertexAttribPointer(posLoc, 2, glContext.FLOAT, false, 0, 0);

		const uTime = glContext.getUniformLocation(prog, 'u_time');
		const uRes = glContext.getUniformLocation(prog, 'u_resolution');
		const uMouse = glContext.getUniformLocation(prog, 'u_mouse');

		const mouse = { x: canvas.width / 2, y: canvas.height / 2 };
		function onMouseMove(event: MouseEvent) {
			const rect = canvas.getBoundingClientRect();
			if (rect.width && rect.height) {
				const nx = (event.clientX - rect.left) / rect.width;
				const ny = 1.0 - (event.clientY - rect.top) / rect.height;
				mouse.x = nx * canvas.width;
				mouse.y = ny * canvas.height;
			}
		}
		window.addEventListener('mousemove', onMouseMove);

		let rafId: number;
		function render(t: number) {
			if (typeof ResizeObserver === 'undefined') syncSize();
			glContext.viewport(0, 0, canvas.width, canvas.height);
			if (uTime) glContext.uniform1f(uTime, t * 0.001);
			if (uRes) glContext.uniform2f(uRes, canvas.width, canvas.height);
			if (uMouse) glContext.uniform2f(uMouse, mouse.x, mouse.y);
			glContext.drawArrays(glContext.TRIANGLE_STRIP, 0, 4);
			rafId = requestAnimationFrame(render);
		}
		rafId = requestAnimationFrame(render);

		return () => {
			cancelAnimationFrame(rafId);
			resizeObserver?.disconnect();
			window.removeEventListener('mousemove', onMouseMove);
		};
	});
</script>

<canvas bind:this={canvasEl} class="pointer-events-none absolute inset-0 h-full w-full"></canvas>
