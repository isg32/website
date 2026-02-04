<script lang="ts">
	// @ts-ignore
	import { rot } from "./cipher"
	import HiddenText from "./HiddenText.svelte"
	import { selectable } from "./selectable"
	import { browser } from "$app/env"

	// sapangajjar101105@gmail.com rot13 encoded
	const email = rot("fncnatnwwne101105@tznvy.pbz", -13)
</script>

<svelte:head>
	<title>About</title>
</svelte:head>

<article class="article">
	<h1>About</h1>
	<div class="profile-card">
		<img
			class="portrait"
			src="https://avatars.githubusercontent.com/u/95901240?v=4"
			alt="Sapan's portrait"
			style="width: 160px; height: 160px"
		/>
		<div class="title">
			<h2>Sapan Gajjar</h2>
			<div class="tagline">Developer | Ahmedabad</div>
		</div>

		<h3>Professional Overview</h3>
		<p>
			Versatile developer with expertise in both low-level systems programming
			and full-stack web and mobile development. Extensive technical background
			includes C, Rust, Python, Java, JavaScript, and Bash. He is proficient in
			a range of frameworks and tools such as React.js, Flask, Flutter,
			Scikit-Learn, Selenium, Supabase, Git, Gerrit, Makefile, and systemd. deep
			understanding of core development platforms including Android, AOSP, and
			Linux. He is experienced in DevOps principles, CI/CD, and automation, with
			practical knowledge of Google Cloud Platform (GCP). Specialized abilities
			include Web Scraping, Data Mining, OEM ROM Modifying and Porting, and
			Front-End Design. With a passion for problem-solving, he is adept at
			tackling complex challenges across various technical domains.
		</p>

		<h3>Work Experience</h3>
		<h4>Plutosolve, Lead Developer</h4>
		<p>
			Ahmedabad (remote), Part-time · Mar 2024 - Present<br />
			Full-Stack Developer with a strong specialization in mobile development (Flutter)
			and DevOps principles (CI/CD, GCP, automation). Capable of building, deploying,
			and maintaining robust applications across the entire stack.
		</p>
		<h4>PixelBuilds, Device Engineer</h4>
		<p>
			Ahmedabad (remote), Community Developer · May 2023 - Feb 2024<br />
			Engineered and maintained Android custom ROMs, focusing on performance optimization,
			security patches, and device-specific modifications. Contributed to open-source
			projects using C, C++, and Rust, and collaborated on a global team via Git
			and Gerrit for code reviews.
		</p>

		<h3>Volunteering Experience</h3>
		<h4>SSIP Gujarat (Syntaxium Club), Lead</h4>
		<p>
			IoT Development, Graphics, and Printing & Merchandise Coordinator<br />
			Ahmedabad · Mar 2024 - Aug 2025 · 1yr, 2mos<br />
			Key member (One Of the Leads) of the Syxtaxium Club, leveraging my expertise
			in UI/UX design and content strategy to create compelling digital experiences.
			Additionally, I contribute to the club's physical presence by overseeing printing
			and merchandise coordination (Id-cards, Leashes, Bagtags, Atriculate Keychains).
		</p>
		<h4>Motorola, Community Developer</h4>
		<p>
			Ahmedabad (remote), Community Developer · May 2023 - Feb 2024<br />
			Engineered and maintained Android custom ROMs For Motorola (device: hanoi/p
			- Moto G60 / G40 Fusion), focusing on performance optimization, security patches,
			and device-specific modifications.
		</p>

		<h3>Key Skill & Technologies</h3>

		<h4>Programming Languages & Frameworks</h4>
		<ul class="list">
			<li>
				<strong>Python:</strong> Proficient in back-end development with Flask and
				data-centric tasks using Scikit-Learn and other libraries for Machine Learning
				and Data Mining.
			</li>
			<li>
				<strong>JavaScript:</strong> Experienced with the React.js framework for
				building dynamic and responsive web applications.
			</li>
			<li>
				<strong>Flutter:</strong> Skilled in cross-platform mobile app development.
			</li>
			<li>
				<strong>Low-Level Languages:</strong> Expertise in C, C++, and Rust for performance-critical
				and embedded systems.
			</li>
			<li>
				<strong>Java and Kotlin:</strong> Knowledgeable in Android application development.
			</li>
			<li>
				<strong>Shell Scripting and Bash:</strong> Experienced in automation and
				system management tasks.
			</li>
		</ul>

		<h4>DevOps & Infrastructure</h4>
		<ul class="list">
			<li>
				<strong>Google Cloud Platform (GCP):</strong> Proficient in deploying and
				managing applications on a major cloud provider.
			</li>
			<li>
				<strong>systemd:</strong> Expertise in managing services and daemons on Linux
				systems.
			</li>
			<li>
				<strong>Git and Gerrit:</strong> Highly skilled in version control and collaborative
				code review processes.
			</li>
			<li>
				<strong>Makefile:</strong> Competent in automating software builds and compilation.
			</li>
			<li>
				<strong>Linux:</strong> Deep understanding of the Linux operating system
				from both a user and a developer perspective.
			</li>
		</ul>

		<h4>Specialized & Other Skills</h4>
		<ul class="list">
			<li>
				Web Development: Strong command of HTML, CSS, JavaScript, and Front-End
				Design.
			</li>
			<li>
				Testing & Automation: Experience with Selenium for web automation and
				testing.
			</li>
			<li>
				Web Scraping and Data Mining: Skilled in gathering and processing data
				from various sources.
			</li>
			<li>
				Mobile Development: Expertise in Android and AOSP (Android Open Source
				Project).
			</li>
			<li>
				Database: Experience with Supabase, a powerful backend-as-a-service.
			</li>
			<li>
				Problem Solving: Proven ability to tackle complex technical challenges
				and innovate.
			</li>
			<li>Multimedia: Basic skills in After Effects.</li>
			<li>
				IoT: Familiar with the concepts and technologies related to the Internet
				of Things.
			</li>
		</ul>

		<h3>Personal Projects Highlight</h3>
		<p>Explore the source code for all my projects on GitHub & Github Org.</p>
		<ul class="list">
			<li>
				<strong>Areax:</strong> - A Basic PropertyEvaluator App Made by me for SIH2025,
				written in Flutter - uses OpenStreetMap Api to function.
			</li>
			<li>
				<strong>paid-detector:</strong> - My First Freelance Project - Basically
				there exists a portal that displays diffrent websites in an iframe, and this
				tool scrapes contents and determines if this.displayed website is relevent
				to us or not, if no - skip, if yes ring a bell and pause for human verification
				and data entry.
			</li>
			<li>
				<strong>Fempeg:</strong> - A very Random gui tool I made, Flac to AAC Converter
				(this is to use offline flac files in Apple Music).
			</li>
			<li>
				<strong>techhunt 2025:</strong> - Terminal UI themed website I using google
				gemini in 3 mins. (exactly) for a college event.
			</li>
			<li>
				<strong>Android Valhalla [deprecated now]:</strong> <a href="#">Link</a>
				- At the time of Android Fifteen's initial release, there were no ROMs to
				build, so I made my own with the resources I had available.
			</li>
			<li>
				<strong>BookPiler:</strong> - Another one of my Freelance Projects, Basically
				take PDFs and Merge Sort them using their data with also inline Header/footer
				designing using pyton. Very Obscure & Out-dated Modules were used.
			</li>
			<li>
				<strong>ID-Gen:</strong> - A tool Made to make Duplicate ID Cards for Colleges,
				EVIL.
			</li>
			<li>
				<strong>VideoSauce:</strong> - My Attempt on making a No Recommendation &
				Straight Forward Netflix.
			</li>
		</ul>

		<h3>Miscellaneous Endeavors</h3>
		<h4>My Youtube Channel</h4>
		<p>
			Mar 2018 - Present<br />
			I post Random Things there. Here is the refrence link in case you want to find
			out!
		</p>
		<h4>Self Hosted Debian Infrastruture</h4>
		<p>
			Located in Ahmedabad (My own home) · May 2025 - Present<br />
			So I Do Self host, Yes I am one of the people who Seed Obscure Torrents so
			that other people can Download The files long lost, I also host my own Netflix,
			Spotify, GoogleDrive (Jellyfin/SwingMusic/SFTP Server) Service with my Own
			Media Collection. You Can Access it here if you have the credentials.
		</p>

		<h3>Contact</h3>

		{#if browser}
			<p>
				If you want to get in touch you can send me a message at:
				<HiddenText>
					<span slot="hidden" aria-label="email is hidden, tap to reveal">
						&lt;tap to show&gt;
					</span>
					<span slot="visible" use:selectable>{email}</span>
				</HiddenText>
			</p>
		{:else}
			<noscript>
				<blockquote>
					Contact info is not shown with JavaScript disabled. This is to prevent
					it from getting picked up by web scrapers. Sorry!
				</blockquote>
			</noscript>
		{/if}
	</div>
</article>

<style>
	.portrait {
		border-radius: 100%;
		float: left;
		margin-right: 2em;
		margin-bottom: 1em;
	}
	.title h2 {
		margin-bottom: 0;
	}
	.tagline {
		color: var(--color-text-300);
		margin-bottom: var(--line-space);
	}

	@media (max-width: 30rem) {
		.portrait {
			display: block;
			float: none;
			margin-left: auto;
			margin-right: auto;
			margin-bottom: calc(0.5 * var(--line-space));
		}

		.title {
			text-align: center;
		}
	}

	[slot="hidden"] {
		cursor: pointer;
		background: var(--color-secondary-200);
		color: var(--color-secondary-200-text);
	}

	[slot="visible"] {
		@keyframes flash {
			from {
				background: var(--color-secondary-400);
				color: var(--color-secondary-400-text);
			}
			to {
				background: transparent;
				color: inherit;
			}
		}

		animation: flash 1s var(--standard-curve);
		border: 1px dashed var(--color-text-100);
	}
</style>
