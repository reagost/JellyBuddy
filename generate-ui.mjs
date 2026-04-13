import { stitch } from '@google/stitch-sdk';

const projectId = '5066721801340088966';
const project = stitch.project(projectId);

console.log('Starting screen generation...');

try {
  // Home Screen
  console.log('Generating Home Screen...');
  const homeScreen = await project.generate(
    'A gamified mobile learning app home screen. Header with user avatar left, notification bell and settings gear right. Hero card showing fire emoji and "7 Day Streak" with progress bar. Below shows "Continue Learning" section with 2 course cards: Python L2 with purple gradient card, JavaScript L1 with orange gradient. Each card shows progress bar and percentage. Daily tasks section with checkboxes. Bottom navigation bar with Home, Courses, AI Tutor, Profile icons. Purple (#6C63FF) primary theme.',
    'MOBILE'
  );
  console.log('Home Screen ID:', homeScreen.id);
  console.log('Home HTML:', await homeScreen.getHtml());
  console.log('Home Image:', await homeScreen.getImage());

  // Course List Screen
  console.log('\nGenerating Course List Screen...');
  const courseScreen = await project.generate(
    'A mobile course catalog screen. Top header with back arrow and title "All Courses". Search bar below. Tab filter: All, Programming, Math, Language. Course cards in grid: Python with 4.9 stars and 12.5k learners, JavaScript with 4.8 stars, C++ with 4.7 stars. Each card shows progress bar. Bottom navigation.',
    'MOBILE'
  );
  console.log('Course Screen ID:', courseScreen.id);
  console.log('Course HTML:', await courseScreen.getHtml());
  console.log('Course Image:', await courseScreen.getImage());

  // Lesson/Quiz Screen
  console.log('\nGenerating Lesson Screen...');
  const lessonScreen = await project.generate(
    'A mobile quiz screen. Top bar showing 5 heart icons (red), lesson title "Python L2-3", and timer 00:45. Progress bar showing 3/5 completed. Question card with Python code snippet asking about variable naming. Four option cards A-D below. Bottom shows "Ask AI Helper" button with lightbulb icon. Purple theme.',
    'MOBILE'
  );
  console.log('Lesson Screen ID:', lessonScreen.id);
  console.log('Lesson HTML:', await lessonScreen.getHtml());
  console.log('Lesson Image:', await lessonScreen.getImage());

  // AI Tutor Screen
  console.log('\nGenerating AI Tutor Screen...');
  const aiScreen = await project.generate(
    'A mobile AI tutor chat screen. Header showing AI avatar "Code Buddy" with thinking animation dots. Chat bubbles: AI message explaining variable naming rules with numbered list, user message asking follow up. Related concept chips at bottom of AI message. Input field with send button. Purple theme with friendly conversational UI.',
    'MOBILE'
  );
  console.log('AI Screen ID:', aiScreen.id);
  console.log('AI HTML:', await aiScreen.getHtml());
  console.log('AI Image:', await aiScreen.getImage());

  // Profile/Achievements Screen
  console.log('\nGenerating Profile Screen...');
  const profileScreen = await project.generate(
    'A mobile profile screen. Header with back arrow and "My Profile" title. User info section: avatar, username "Code Learner", Level 12 badge, XP 2,450 / 3,000 to next level. Stats row: 156 lessons, 42 day streak, 28 achievements. Achievement badges grid: green checkmark for completed (First Step, Streak Master), yellow in-progress for Perfectionist 3/10, gray locked for others. Bottom navigation.',
    'MOBILE'
  );
  console.log('Profile Screen ID:', profileScreen.id);
  console.log('Profile HTML:', await profileScreen.getHtml());
  console.log('Profile Image:', await profileScreen.getImage());

  console.log('\n=== All screens generated successfully! ===');
} catch (error) {
  console.error('Error:', error.message);
  if (error.code) console.error('Code:', error.code);
}
