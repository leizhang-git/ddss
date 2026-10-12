module.exports = {
  root: true,
  parserOptions: {
    parser: 'babel-eslint',
    ecmaVersion: 2020,
    sourceType: 'module'
  },
  env: {
    browser: true,
    node: true,
    es6: true
  },
  extends: [
    'plugin:vue/recommended'
  ],
  plugins: ['vue'],
  rules: {
    'no-console': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'off',
    'vue/multi-word-component-names': 'off',
    'vue/no-v-html': 'warn',
    // 存量 Vue2 页面使用对象式表单双向绑定；作为迁移告警，不阻断生产构建。
    'vue/no-mutating-props': 'warn',
    'vue/no-side-effects-in-computed-properties': 'warn',
    'vue/require-prop-types': 'warn',
    'vue/require-default-prop': 'warn',
    'vue/require-valid-default-prop': 'warn',
    'vue/attribute-hyphenation': 'off',
    'semi': ['error', 'never'],
    'quotes': ['error', 'single', {allowTemplateLiterals: true}],
    'indent': ['error', 2, {SwitchCase: 1}],
    'comma-dangle': ['error', 'never']
  }
}
